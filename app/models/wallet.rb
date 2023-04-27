# frozen_string_literal: true

class Wallet < ApplicationRecord
  validates :name,      presence: true, uniqueness: true
  validates :password,  presence: true
  validates :rpc_creds, presence: true
  validates :port,      presence: true, uniqueness: true

  encrypts :password, :rpc_creds

  def running?
    return false if pid.blank?

    File.read("/proc/#{pid}/cmdline").match?(%r{monero-wallet-rpc.*--config-file=wallets/#{name}.config})
  rescue Errno::ENOENT
    false
  end

  def run!
    return if running?

    write_config_file!
    pid = spawn("monero-wallet-rpc --config-file=wallets/#{name}.config")
    update(pid:)
    Process.detach(pid)
  end

  private

  def write_config_file!
    File.open("wallets/#{name}.config", 'w') do |f|
      f.puts 'stagenet=true'
      f.puts 'daemon-host=stagenet.community.rino.io'
      f.puts "wallet-file=wallets/#{name}"
      f.puts "password=#{password}"
      f.puts "rpc-login=#{rpc_creds}"
      f.puts "rpc-bind-port=#{port}"
      f.puts "tx-notify=/home/snex/github/xpg/process_tx.sh #{id} %s"
    end

    FileUtils.chmod('u=rw', "wallets/#{name}.config")
  end
end
