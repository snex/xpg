# frozen_string_literal: true

require 'rails_helper'
RSpec.describe CreateRpcWalletJob, type: :job do
  let(:wallet) { create(:wallet) }

  before do
    allow(Wallet).to receive(:find).with(wallet.id).and_return(wallet)
    allow(wallet).to receive(:create_rpc_wallet_file!)
    described_class.new.perform(wallet.id, 'a', '1', 2)
  end

  it 'finds the supplied wallet' do
    expect(Wallet).to have_received(:find).with(wallet.id).once
  end

  it 'creates the specified wallet' do
    expect(wallet).to have_received(:create_rpc_wallet_file!).once
  end
end
