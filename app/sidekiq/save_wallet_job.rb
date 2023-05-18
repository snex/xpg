# frozen_string_literal: true

class SaveWalletJob
  include Sidekiq::Job

  def perform(wallet_id)
    Wallet.find(wallet_id).save_wallet_file!
  end
end
