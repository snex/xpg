# frozen_string_literal: true

class Wallet < ApplicationRecord
  validates :name,     presence: true, uniqueness: true
  validates :password, presence: true
  validates :port,     presence: true, uniqueness: true

  encrypts :password

  def running?
    return false if pid.blank?

    File.read("/proc/#{pid}/cmdline").match?(%r{monero-wallet-rpc .* --wallet-file=wallets/#{name} .* --rpc-bind-port=#{port}})
  rescue Errno::ENOENT
    false
  end

  def run!
    return if running?

    pid = spawn("monero-wallet-rpc --stagenet --daemon-host=stagenet.community.rino.io --wallet-file=wallets/#{name} --password='#{password}' --rpc-login='monero:password' --rpc-bind-port=#{port} --tx-notify='/home/snex/github/xpg/process_tx.sh #{id} %s'")
    update(pid:)
    Process.detach(pid)
  end
end
