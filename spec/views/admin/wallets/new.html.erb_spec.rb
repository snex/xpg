# frozen_string_literal: true

RSpec.describe 'admin/wallets/new' do
  before do
    assign(:wallet, Wallet.new(
                      name:     'MyString',
                      password: 'MyString',
                      port:     1,
                      pid:      1
                    ))
    render
  end

  it 'renders new wallet form name input' do
    assert_select 'form[action=?][method=?]', admin_wallets_path, 'post' do
      assert_select 'input[name=?]', 'wallet[name]'
    end
  end

  it 'renders new wallet form port input' do
    assert_select 'form[action=?][method=?]', admin_wallets_path, 'post' do
      assert_select 'input[name=?]', 'wallet[port]'
    end
  end
end
