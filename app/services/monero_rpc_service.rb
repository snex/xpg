# frozen_string_literal: true

class MoneroRpcService
  def initialize(wallet)
    @wallet = wallet
    user, pass = @wallet.rpc_creds.split(':')
    @rpc = MoneroRPC.new(host: '127.0.0.1', port: wallet.port, username: user, password: pass)
    @drpc = MoneroRPC.new(
      host:     Rails.application.config.monero_daemon,
      port:     Rails.application.config.monero_daemon_port,
      username: '',
      password: ''
    )
  end

  def current_height
    @drpc.get_info['height']
  end

  def create_rpc_wallet(address, view_key)
    @rpc.generate_view_wallet(@wallet.name, address, @wallet.password, view_key, current_height)
    @rpc.stop_wallet
  end

  def create_incoming_address
    @rpc.create_address['address']
  end
end
