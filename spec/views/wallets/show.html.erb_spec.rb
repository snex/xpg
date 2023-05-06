# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/show' do
  let(:wallet) { create(:wallet) }

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
end
