# frozen_string_literal: true

module WalletFileService
  class CreateWalletFileService
    include WalletFileService

    def config
      Rails.configuration.monero_wallet_rpc.create_wallet
    end

    def spawn_wallet_proc!
      pid = spawn("monero-wallet-rpc --config-file=wallets/#{@wallet.name}.config")
      CreateRpcWalletJob.perform_async(@wallet.id)
      Process.wait2(pid)
    end
  end
end
