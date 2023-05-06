# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/index' do
  let(:wallets) { create_list(:named_wallet, 2, pid: 3) }

  before do
    allow(wallets.first).to receive(:status).and_return(:running)
    allow(wallets.last).to receive(:status).and_return(:running)
    assign(:wallets, wallets)
  end

  it 'renders a list of wallets' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: /Name/, count: 2
    assert_select cell_selector, text: /1000/, count: 2
  end
end
