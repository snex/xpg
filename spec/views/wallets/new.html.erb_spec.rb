# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/new' do
  before do
    assign(:wallet, Wallet.new(
                      name: 'MyString',
                      password: 'MyString',
                      port: 1,
                      pid: 1
                    ))
  end

  it 'renders new wallet form' do
    render

    assert_select 'form[action=?][method=?]', wallets_path, 'post' do
      assert_select 'input[name=?]', 'wallet[name]'

      assert_select 'input[name=?]', 'wallet[password]'

      assert_select 'input[name=?]', 'wallet[port]'

      assert_select 'input[name=?]', 'wallet[pid]'
    end
  end
end
