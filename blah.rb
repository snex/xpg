# frozen_string_literal: true

require 'monero'
require 'active_support/inflector'

d_rpc = MoneroRPC.new(
  host:     'stagenet.community.rino.io',
  port:     '38081',
  username: '',
  password: ''
)

puts d_rpc.get_info['height']

rpc = MoneroRPC.new(
  host:     '127.0.0.1',
  port:     '12345',
  username: 'abffa309461c77ba92462e6046976e62',
  password: 'cd10c0a5df5532d1f99ddfde705bd34e'
)

puts 'wallet 1 info'
puts '========================================================'
puts rpc.get_accounts
puts rpc.get_addresses
puts rpc.balance
puts rpc.unlocked_balance

# new_addr = rpc.create_address
# new_addr_idx = new_addr['address_index']
# new_addr_addr = new_addr['address']
# puts new_addr
# puts rpc.create_transfer(new_addr_addr, 1000000000000)
