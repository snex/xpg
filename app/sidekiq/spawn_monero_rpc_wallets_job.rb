# frozen_string_literal: true

class SpawnMoneroRpcWalletsJob
  include Sidekiq::Job

  def perform
    Wallet.all.each do |wallet|
      wallet.update_pid!
      MoneroRpcWalletJob.perform_async(wallet.id)
    end
  end
end
