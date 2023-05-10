# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WalletCreator do
  it 'includes ActiveModel::Model' do
    expect(described_class.ancestors).to include(ActiveModel::Model)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:view_key) }

    describe '#validate_wallet' do
      subject(:valid?) { wc.valid? }

      let!(:wc) { described_class.new }
      let!(:wallet) { build(:wallet) }

      before do
        allow(wc).to receive(:wallet).and_return(wallet)
        allow(wallet).to receive(:valid?)
      end

      it 'calls wallet.valid?' do
        valid?

        expect(wallet).to have_received(:valid?).once
      end
    end
  end

  describe 'delegators' do
    it { is_expected.to delegate_method(:to_param).to(:wallet) }
  end

  describe '.model_name' do
    subject { described_class.model_name }

    it { is_expected.to eq(Wallet.model_name) }
  end

  describe '#save' do
    subject(:save) { wc.save }

    let!(:wc) { described_class.new(address: 'a', view_key: '1') }
    let!(:wallet) { build(:wallet) }

    before do
      allow(wc).to receive(:wallet).and_return(wallet)
      allow(wallet).to receive(:save!).and_call_original
    end

    context 'when WalletCreator is invalid' do
      before { allow(wc).to receive(:invalid?).and_return(true) }

      it { is_expected.to be_nil }

      it 'does not call wallet.save!' do
        save

        expect(wallet).not_to have_received(:save!)
      end

      it 'does not enqueue a SpawnCreateRpcWalletJob' do
        save

        expect(SpawnCreateRpcWalletJob).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when WalletCreator is valid' do
      before { allow(wc).to receive(:invalid?).and_return(false) }

      it 'calls wallet.save!' do
        save

        expect(wallet).to have_received(:save!)
      end

      it 'enqueues a SpawnCreateRpcWalletJob' do
        save

        expect(SpawnCreateRpcWalletJob).to have_enqueued_sidekiq_job(wallet.id, 'a', '1')
      end
    end
  end
end
