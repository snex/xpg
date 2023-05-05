# frozen_string_literal: true

class CreateRpcWalletJob
  include Sidekiq::Job

  def perform(wallet_id, address, view_key, restore_height)
    Wallet.find(wallet_id).create_rpc_wallet_file!(address, view_key, restore_height)
  end
end
