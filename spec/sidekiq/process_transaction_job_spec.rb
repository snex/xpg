# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessTransactionJob, type: :job do
  let(:wallet) { create(:wallet) }

  before do
    allow(Wallet).to receive(:find).with(wallet.id).and_return(wallet)
    allow(wallet).to receive(:process_transaction)
    described_class.new.perform(wallet.id, '1234')
  end

  it 'finds the supplied wallet' do
    expect(Wallet).to have_received(:find).with(wallet.id).once
  end

  it 'calls process_transaction on the specified wallet' do
    expect(wallet).to have_received(:process_transaction).with('1234').once
  end
end
