# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :wallet

  has_many :payments, dependent: :restrict_with_error

  has_one_attached :qr_code

  validates :amount,           presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :expires_at,       presence: true
  validates :external_id,      presence: true, uniqueness: { scope: :wallet_id }
  validates :incoming_address, uniqueness: { scope: :payment_id }
  validates :callback_url,     presence: true, url: true

  encrypts :amount, :callback_url
  # Need deterministic encryption in order to support search and unique constraint
  encrypts :incoming_address, :payment_id, :external_id, deterministic: true

  before_validation :assign_expires_at
  before_create :generate_incoming_address, :generate_qr_code

  scope :expired, -> { where(expires_at: ..Time.current) }

  def estimated_confirm_time
    monero_rpc_service.estimated_confirm_time(amount.to_i)
  end

  def amount_paid
    @amount_paid ||= payments.select(&:confirmed?).pluck(:amount).map(&:to_i).sum
  end

  def paid?
    amount_paid >= amount.to_i
  end

  def unpaid?
    !paid?
  end

  def paid_unconfirmed?
    payments.pluck(:amount).map(&:to_i).sum >= amount.to_i && unpaid?
  end

  def overpaid?
    amount_paid > amount.to_i
  end

  def partially_paid?
    unpaid? && amount_paid.positive?
  end

  def handle_payment_complete
    CallbackService.handle_payment_complete(callback_url)
    gracefully_delete(skip_delete_paid: false)
  end

  def handle_overpayment
    InvoiceMailer.with(invoice: self).overpayment.deliver_now if MailConfig.enabled?
    HandlePaymentCompleteJob.perform_async(id)
  end

  def handle_partial_payment
    InvoiceMailer.with(invoice: self).partial_payment.deliver_now if MailConfig.enabled?
    DeleteInvoiceJob.perform_async(id)
  end

  def gracefully_delete(skip_delete_paid: true)
    # do not delete an invoice if it is fully paid but still awaiting confirmations. it will be picked up later
    return if paid_unconfirmed?

    # do not delete an invoice if it was fully paid via the sidekiq job.
    # it will be deleted after running the CallbackService
    return if paid? && skip_delete_paid

    if partially_paid?
      handle_partial_payment
      payments.destroy_all
    else
      payments.destroy_all
      qr_code.purge
      destroy
    end
  end

  private

  def assign_expires_at
    return if expires_at?
    return unless wallet_id?

    # Rails has not yet set the wallet object
    wallet ||= Wallet.find(wallet_id)
    return unless wallet.default_expiry_ttl?

    self.expires_at = Time.current + wallet.default_expiry_ttl.minutes
  end

  def monero_rpc_service
    @monero_rpc_service ||= MoneroRpcService.new(wallet)
  end

  def generate_incoming_address
    return if incoming_address? && payment_id?

    integrated_address = monero_rpc_service.generate_incoming_address
    self.incoming_address ||= integrated_address['integrated_address']
    self.payment_id ||= integrated_address['payment_id']
  end

  def generate_qr_code
    return if qr_code.attached?

    payment_uri = monero_rpc_service.generate_uri(incoming_address, amount)
    qr_code.attach(
      io:       StringIO.new(RQRCode::QRCode.new(payment_uri).as_svg),
      filename: "#{incoming_address}.svg"
    )
  end
end
