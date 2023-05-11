# frozen_string_literal: true

RSpec.describe 'wallets/status' do
  let(:wallet) { create(:wallet) }

  before do
    allow(wallet).to receive(:status).and_return(test_status)
    assign(:wallet, wallet)
    render
  end

  context 'when the wallet is running' do
    let(:test_status) { :running }

    it 'uses the color green' do
      expect(rendered).to match(/color: green/)
    end

    it 'renders the running status' do
      expect(rendered).to match(/Running \(pid: #{wallet.pid}\)/)
    end
  end

  context 'when the wallet is building' do
    let(:test_status) { :building }

    it 'uses the color orange' do
      expect(rendered).to match(/color: orange/)
    end

    it 'renders the building status' do
      expect(rendered).to match(/Building Monero wallet/)
    end
  end

  context 'when the wallet is in error state' do
    let(:test_status) { :error }

    it 'uses the color red' do
      expect(rendered).to match(/color: red/)
    end

    it 'renders the building status' do
      expect(rendered).to match(/Not Running/)
    end
  end
end
