# frozen_string_literal: true

require 'sidekiq-scheduler'

class SpawnMoneroRpcWalletsJob
  include Sidekiq::Job

  def perform
    Wallet.pluck(:id).each do |wallet_id|
      MoneroRpcWalletJob.perform_async(wallet_id)
    end
  end
end
