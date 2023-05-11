# frozen_string_literal: true

RSpec.describe 'wallets/index' do
  let(:wallets) { create_list(:named_wallet, 2, pid: 3) }

  before do
    allow(wallets.first).to receive(:status).and_return(:running)
    allow(wallets.last).to receive(:status).and_return(:running)
    assign(:wallets, wallets)
  end

  it 'renders a list of wallets' do
    render
    assert_select 'div>h2', text: /Name/, count: 2
    assert_select 'div>p', text: /1000/, count: 2
  end
end
