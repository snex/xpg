# frozen_string_literal: true

class MoneroRpcService
  def initialize(wallet)
    @wallet = wallet
    user, pass = @wallet.rpc_creds.split(':')
    @rpc = MoneroRPC.new(host: '127.0.0.1', port: wallet.port, username: user, password: pass)
  end

  def create_rpc_wallet
    @rpc.create_wallet(@wallet.name, @wallet.password)
    @rpc.stop_wallet
  end
end
