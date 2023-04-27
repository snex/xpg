# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/index' do
  before do
    assign(:wallets, [
             Wallet.create!(
               name: 'Name 1',
               password: 'Password',
               rpc_creds: 'rpc:pass',
               port: 11_110,
               pid: 3
             ),
             Wallet.create!(
               name: 'Name 2',
               password: 'Password',
               rpc_creds: 'rpc:pass',
               port: 11_111,
               pid: 3
             )
           ])
  end

  it 'renders a list of wallets' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Name'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(1111.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
  end
end
