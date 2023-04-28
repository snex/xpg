# frozen_string_literal: true

class CreateRpcWalletJob
  include Sidekiq::Job

  def perform(wallet_id)
    Wallet.find(wallet_id).create_rpc_wallet_file!
  end
end
