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

  def status
    status = [payment_status]
    status << expiration_status if status.include?(:unpaid)

    status
  end

  private

  def assign_expires_at
    return if expires_at?
    return unless wallet_id?

    # Rails has not yet set the wallet object
    wallet ||= Wallet.find(wallet_id)
    return unless wallet.default_expiry_ttl?

    self.expires_at = Time.current + wallet.default_expiry_ttl&.minutes
  end

  def generate_incoming_address
    return if incoming_address? && payment_id?

    integrated_address = wallet.generate_incoming_address
    self.incoming_address ||= integrated_address['integrated_address']
    self.payment_id ||= integrated_address['payment_id']
  end

  def generate_qr_code
    payment_uri = XMR.new(amount).pmt_uri(incoming_address, payment_id)
    qr_code.attach(
      io:       StringIO.new(RQRCode::QRCode.new(payment_uri).as_svg),
      filename: "#{incoming_address}.svg"
    )
  end

  def payment_status
    # encrypted column means we cant sum it in the database
    amount_paid = payments.pluck(:amount).map(&:to_i).sum

    if amount_paid > amount.to_i
      :overpaid
    elsif amount_paid < amount.to_i
      :unpaid
    else
      :paid
    end
  end

  def expiration_status
    if Time.current < expires_at
      :payable
    else
      :overdue
    end
  end
end
