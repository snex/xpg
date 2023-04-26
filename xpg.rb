# frozen_string_literal: true

require 'active_support/inflector'
require 'monero'
require 'sinatra'

MoneroRPC.config.debug = true
MoneroRPC.config.username = 'monero'
MoneroRPC.config.password = 'password'

post '/process_tx/:tx_id/:port' do
  $rpc = MoneroRPC.new(host: '127.0.0.1', port: params['port'])
  puts "We got a transaction! #{$rpc.get_transfer_by_txid(params['tx_id'])}"
end
