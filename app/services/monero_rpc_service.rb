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

  def avg_block_time(num_blocks = 720)
    Rails.cache.fetch('xpg:avg_block_time', expires_in: 1.hour) do
      last_n_block_headers(num_blocks)
        .pluck('timestamp')
        .each_cons(2)
        .map { |timestamp| timestamp.last - timestamp.first }
        .sum / (num_blocks - 1)
    end
  end

  def estimated_confirm_time(amount)
    reward = @drpc.get_last_block_header['block_header']['reward']

    ((avg_block_time * (amount / reward).clamp(1, 10)) / 60).minutes
  end

  def create_rpc_wallet(address, view_key)
    @rpc.generate_view_wallet(@wallet.name, address, @wallet.password, view_key, current_height)
    @rpc.stop_wallet
  end

  def save_wallet
    @rpc.save_wallet
  end

  def generate_incoming_address
    @rpc.make_integrated_address
  end

  def generate_uri(address, amount)
    @rpc.make_uri(address, amount)['uri']
  end

  def transfer_details(tx_id)
    @rpc.get_transfer_by_txid(tx_id)
  end

  private

  def last_n_block_headers(num_blocks)
    cur_height = current_height
    @drpc.get_block_headers_range(cur_height - num_blocks - 1, cur_height - 1)['headers']
  end
end
