# frozen_string_literal: true

module WalletFileService
  class CreateWalletFileService
    include WalletFileService

    def config
      Rails.configuration.monero_wallet_rpc.create_wallet
    end

    def spawn_wallet_proc!(address, view_key)
      pid = Process.spawn("monero-wallet-rpc --config-file=wallets/#{@wallet.name}.config")
      CreateRpcWalletJob.perform_in(30.seconds, @wallet.id, address, view_key)
      Process.wait2(pid)
    end
  end
end
