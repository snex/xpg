# frozen_string_literal: true

RSpec.describe '/admin/wallets/index' do
  let(:wallets) do
    [
      create(:wallet, port: 12_345, default_expiry_ttl: 60),
      create(:wallet, port: 12_346, default_expiry_ttl: nil)
    ]
  end

  before do
    allow(wallets.first).to receive(:status).and_return(:running)
    allow(wallets.last).to receive(:status).and_return(:running)
    assign(:wallets, wallets)
    render
  end

  it 'renders wallet names' do
    assert_select 'div>h2>a', text: /Wallet-/, count: 2
  end

  it 'renders wallet ports' do
    assert_select 'div>p', text: /12345/, count: 1
    assert_select 'div>p', text: /12346/, count: 1
  end

  it 'renders wallet default_expiry_ttls' do
    assert_select 'div>p', text: /60 minutes/, count: 1
    assert_select 'div>p', text: %r{N/A}, count: 1
  end
end
