# frozen_string_literal: true

RSpec.describe 'wallets/show' do
  let(:wallet) { create(:wallet, :with_default_expiry_ttl) }

  before do
    assign(:wallet, wallet)
    render
  end

  it 'renders name' do
    expect(rendered).to match(/#{wallet.name}/)
  end

  it 'renders port' do
    expect(rendered).to match(/#{wallet.port}/)
  end

  it 'renders default_expiry_ttl' do
    expect(rendered).to match(/#{wallet.default_expiry_ttl}/)
  end
end
