# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'wallets/show' do
  before do
    assign(:wallet, Wallet.create!(
                      name: 'Name',
                      password: 'Password',
                      port: 2,
                      pid: 3
                    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Password/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
