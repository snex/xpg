# frozen_string_literal: true

RSpec.describe SaveWalletJob, type: :job do
  let(:wallet) { create(:wallet) }

  before do
    allow(Wallet).to receive(:find).with(wallet.id).and_return(wallet)
    allow(wallet).to receive(:save_wallet_file!)
    described_class.new.perform(wallet.id)
  end

  it 'finds the supplied wallet' do
    expect(Wallet).to have_received(:find).with(wallet.id).once
  end

  it 'saves the specified wallet file' do
    expect(wallet).to have_received(:save_wallet_file!).once
  end
end
