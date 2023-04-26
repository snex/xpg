# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/edit' do
  let(:wallet) do
    Wallet.create!(
      name: 'MyString',
      password: 'MyString',
      port: 1,
      pid: 1
    )
  end

  before do
    assign(:wallet, wallet)
  end

  it 'renders the edit wallet form' do
    render

    assert_select 'form[action=?][method=?]', wallet_path(wallet), 'post' do
      assert_select 'input[name=?]', 'wallet[name]'

      assert_select 'input[name=?]', 'wallet[password]'

      assert_select 'input[name=?]', 'wallet[port]'

      assert_select 'input[name=?]', 'wallet[pid]'
    end
  end
end
