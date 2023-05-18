# frozen_string_literal: true

RSpec.describe SaveWalletsJob, type: :job do
  let!(:wallet) { create(:wallet) }

  it 'enqueues a SaveWalletJob for the wallet' do
    described_class.new.perform

    expect(SaveWalletJob).to have_enqueued_sidekiq_job(wallet.id)
  end
end
