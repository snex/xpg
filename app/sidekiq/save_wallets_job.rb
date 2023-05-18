# frozen_string_literal: true

class SaveWalletsJob
  include Sidekiq::Job

  def perform
    Wallet.pluck(:id).each do |wallet_id|
      SaveWalletJob.perform_async(wallet_id)
    end
  end
end
