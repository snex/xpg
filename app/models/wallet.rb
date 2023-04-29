# frozen_string_literal: true

class Wallet < ApplicationRecord
  has_many :invoices, dependent: :restrict_with_error

  validates :name,         presence: true, uniqueness: true
  validates :password,     presence: true
  validates :port,         presence: true, uniqueness: true

  encrypts :password, :rpc_creds

  after_initialize :assign_file_service
  before_create :generate_rpc_creds
  after_commit :create_rpc_wallet_async!, on: :create

  attr_accessor :file_service

  def create_rpc_wallet!
    return if ready_to_run?

    file_service.write_config_file!
    file_service.spawn_wallet_proc!
  end

  def create_rpc_wallet_file!
    MoneroRpcService.new(self).create_rpc_wallet
    update(ready_to_run: true)
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

  def assign_file_service
    self.file_service = if ready_to_run?
                          WalletFileService::RpcWalletFileService.new(self)
                        else
                          WalletFileService::CreateWalletFileService.new(self)
                        end
  end

  def generate_rpc_creds
    user = SecureRandom.hex
    pass = SecureRandom.hex
    self.rpc_creds = "#{user}:#{pass}"
  end

  def create_rpc_wallet_async!
    SpawnCreateRpcWalletJob.perform_async(id)
  end
end
