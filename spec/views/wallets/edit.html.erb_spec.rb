# frozen_string_literal: true

RSpec.describe 'wallets/edit' do
  let(:wallet) { create(:wallet) }

  before do
    assign(:wallet, wallet)
    render
  end

  it 'renders the edit wallet form port input' do
    assert_select 'form[action=?][method=?]', wallet_path(wallet), 'post' do
      assert_select 'input[name=?]', 'wallet[port]'
    end
  end
end
