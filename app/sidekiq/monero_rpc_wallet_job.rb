# frozen_string_literal: true

class MoneroRpcWalletJob
  include Sidekiq::Job

  def perform(wallet_id)
    Wallet.find(wallet_id).run!
  end
end
