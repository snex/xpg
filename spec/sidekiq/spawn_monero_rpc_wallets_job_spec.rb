# frozen_string_literal: true

require 'rails_helper'
RSpec.describe SpawnMoneroRpcWalletsJob, type: :job do
  let!(:wallet) { create(:wallet) }

  it 'enqueues a MoneroRpcWalletJob for the wallet' do
    described_class.new.perform

    expect(MoneroRpcWalletJob).to have_enqueued_sidekiq_job(wallet.id)
  end
end
