# frozen_string_literal: true

module WalletFileService
  class RpcWalletFileService
    include WalletFileService

    def config
      Rails.configuration.monero_wallet_rpc.rpc_wallet
    end

    def spawn_wallet_proc!
      pid = spawn("monero-wallet-rpc --config-file=wallets/#{@wallet.name}.config")
      @wallet.update(pid: pid)
      Process.detach(pid)
    end
  end
end
