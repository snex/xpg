# frozen_string_literal: true

class Wallet < ApplicationRecord
  has_many :invoices, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :name, format: { with: /\A[a-zA-Z]+[\w-]*\z/, message: I18n.t('wallet.name_format_error') }
  validates :port, presence: true, uniqueness: true
  validates :default_expiry_ttl, numericality: { only_integer: true, allow_nil: true }

  encrypts :password, :rpc_creds

  before_validation :generate_creds

  def create_rpc_wallet!(address, view_key)
    return if ready_to_run?

    file_service.write_config_file!
    file_service.spawn_wallet_proc!(address, view_key)
  end

  def create_rpc_wallet_file!(address, view_key)
    monero_rpc_service.create_rpc_wallet(address, view_key)
    update(ready_to_run: true)
  end

  def transfer_details(monero_tx_id)
    monero_rpc_service&.transfer_details(monero_tx_id)
  end

  def process_transaction(monero_tx_id)
    # the RPC wallet can trigger multiple notifications per tx, so just quit if we already saw it
    return if Payment.exists?(monero_tx_id: monero_tx_id)

    tx_details = transfer_details(monero_tx_id)
    invoice = invoices.find_by(payment_id: tx_details.payment_id)

    if invoice.blank?
      handle_invoiceless_payment(tx_details)
      return
    end

    # TODO: do something with unlock time?
    payment = Payment.create!(invoice: invoice, amount: tx_details.amount, monero_tx_id: monero_tx_id)
    CheckPaymentConfirmationsJob.perform_async(payment.id)
  end

  def handle_invoiceless_payment(tx_details)
    WalletMailer.with(wallet: self, transaction: tx_details).payment_without_invoice.deliver_now if MailConfig.enabled?
  end

  def status
    return :running if running?
    return :building unless ready_to_run?

    :error
  end

  def running?
    return false if pid.blank?

    File.read("/proc/#{pid}/cmdline").match?(%r{monero-wallet-rpc.*--config-file=wallets/#{name}.config})
  rescue Errno::ENOENT
    update(pid: nil)
    false
  end

  def run!
    return if running? || !ready_to_run?

    file_service.write_config_file!
    file_service.spawn_wallet_proc!
  end

  private

  def file_service
    @file_service ||= if ready_to_run?
                        WalletFileService::RpcWalletFileService.new(self)
                      else
                        WalletFileService::CreateWalletFileService.new(self)
                      end
  end

  def monero_rpc_service
    return unless rpc_creds?

    @monero_rpc_service ||= MoneroRpcService.new(self)
  end

  def generate_creds
    self.password ||= SecureRandom.hex
    rpc_user = SecureRandom.hex
    rpc_pass = SecureRandom.hex
    self.rpc_creds ||= "#{rpc_user}:#{rpc_pass}"
  end
end
