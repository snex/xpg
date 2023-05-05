# frozen_string_literal: true

class SpawnCreateRpcWalletJob
  include Sidekiq::Job

  def perform(wallet_id, address, view_key, restore_height)
    Wallet.find(wallet_id).create_rpc_wallet!(address, view_key, restore_height)
  end
end
