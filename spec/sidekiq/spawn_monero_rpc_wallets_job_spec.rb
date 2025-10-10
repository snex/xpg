# frozen_string_literal: true

RSpec.describe SpawnMoneroRpcWalletsJob, type: :job do
  let!(:wallet) { create(:wallet) }

  before do
    allow(Wallet).to receive(:find_each).and_yield(wallet)
    allow(wallet).to receive(:update_pid!)
  end

  it 'calls update_pid! on the wallet' do
    described_class.new.perform

    expect(wallet).to have_received(:update_pid!).once
  end

  it 'enqueues a MoneroRpcWalletJob for the wallet' do
    described_class.new.perform

    expect(MoneroRpcWalletJob).to have_enqueued_sidekiq_job(wallet.id)
  end
end
