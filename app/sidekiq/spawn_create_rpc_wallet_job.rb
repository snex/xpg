# frozen_string_literal: true

class SpawnCreateRpcWalletJob
  include Sidekiq::Job

  def perform(wallet_id)
    Wallet.find(wallet_id).create_rpc_wallet!
  end
end
