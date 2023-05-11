# frozen_string_literal: true

RSpec.describe MoneroRpcWalletJob, type: :job do
  let(:wallet) { create(:wallet) }

  before do
    allow(Wallet).to receive(:find).with(wallet.id).and_return(wallet)
    allow(wallet).to receive(:run!)
    described_class.new.perform(wallet.id)
  end

  it 'finds the supplied wallet' do
    expect(Wallet).to have_received(:find).with(wallet.id).once
  end

  it 'runs the specified wallet' do
    expect(wallet).to have_received(:run!).once
  end
end
