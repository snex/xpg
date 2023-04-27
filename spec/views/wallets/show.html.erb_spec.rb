# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/show' do
  before do
    assign(:wallet, Wallet.create!(
                      name: 'Name',
                      password: 'Password',
                      rpc_creds: 'rpc:pass',
                      port: 2,
                      pid: 3
                    ))
    render
  end

  it 'renders name' do
    expect(rendered).to match(/Name/)
  end

  it 'renders port' do
    expect(rendered).to match(/2/)
  end

  it 'renders pid' do
    expect(rendered).to match(/3/)
  end
end
