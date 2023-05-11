# frozen_string_literal: true

RSpec.describe SpawnCreateRpcWalletJob, type: :job do
  let(:wallet) { create(:wallet) }

  before do
    allow(Wallet).to receive(:find).with(wallet.id).and_return(wallet)
    allow(wallet).to receive(:create_rpc_wallet!)
    described_class.new.perform(wallet.id, 'a', '1')
  end

  it 'finds the supplied wallet' do
    expect(Wallet).to have_received(:find).with(wallet.id).once
  end

  it 'creates the specified wallet' do
    expect(wallet).to have_received(:create_rpc_wallet!).once
  end
end
