# frozen_string_literal: true

class Wallet < ApplicationRecord
  has_many :invoices, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
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

  def generate_incoming_address
    monero_rpc_service&.generate_incoming_address
  end

  def process_transaction(monero_tx_id)
    tx_details = monero_rpc_service.transfer_details(monero_tx_id)
    payment_id = tx_details['transfer']['payment_id']
    amount = tx_details['transfer']['amount']
    invoice = invoices.find_by(payment_id: payment_id)

    return if invoice.blank?

    # TODO: do something with unlock time?
    # TODO: enqueue a job to check the payment for confirmations?
    Payment.create!(invoice: invoice, amount: amount, monero_tx_id: monero_tx_id)

    # TODO: ping the callback url and record the result
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
