# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/show' do
  let(:wallet) { create(:wallet) }
  let(:test_status) { :running }

  before do
    allow(wallet).to receive(:status).and_return(test_status)
    assign(:wallet, wallet)
    render
  end

  it 'renders name' do
    expect(rendered).to match(/#{wallet.name}/)
  end

  it 'renders port' do
    expect(rendered).to match(/#{wallet.port}/)
  end

  context 'when the wallet is running' do
    let(:test_status) { :running }

    it 'renders the running status' do
      expect(rendered).to match(/Running \(pid: #{wallet.pid}\)/)
    end
  end

  context 'when the wallet is building' do
    let(:test_status) { :building }

    it 'renders the building status' do
      expect(rendered).to match(/Building Monero wallet/)
    end
  end

  context 'when the wallet is in error state' do
    let(:test_status) { :error }

    it 'renders the building status' do
      expect(rendered).to match(/Error/)
    end
  end
end
