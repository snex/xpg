# frozen_string_literal: true

require 'monero'
require 'active_support/inflector'

$rpc_1 = MoneroRPC.new(host: '127.0.0.1', port: '12345', username: 'monero', password: 'password')
$rpc_2 = MoneroRPC.new(host: '127.0.0.1', port: '12346', username: 'monero', password: 'password')

puts 'wallet 1 info'
puts '========================================================'
puts $rpc_1.get_accounts
puts $rpc_1.get_addresses
puts $rpc_1.balance
puts $rpc_1.unlocked_balance

puts ''

puts 'wallet 2 info'
puts '========================================================'
puts $rpc_2.get_accounts
puts $rpc_2.get_addresses
puts $rpc_2.balance
puts $rpc_2.unlocked_balance

# new_addr = $rpc_2.create_address
# new_addr_idx = new_addr['address_index']
# new_addr_addr = new_addr['address']
# puts new_addr
# puts $rpc_1.create_transfer(new_addr_addr, 1000000000000)
