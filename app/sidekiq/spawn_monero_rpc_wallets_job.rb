# frozen_string_literal: true

class SpawnMoneroRpcWalletsJob
  include Sidekiq::Job

  def perform
    Wallet.find_each do |wallet|
      wallet.update_pid!
      MoneroRpcWalletJob.perform_async(wallet.id)
    end
  end
end
