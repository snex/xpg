# frozen_string_literal: true

RSpec.describe WalletFileService::CreateWalletFileService do
  let(:wallet) { create(:wallet) }
  let(:cwfs) { described_class.new(wallet) }

  describe '#config' do
    subject { cwfs.config }

    it { is_expected.to eq(Rails.configuration.monero_wallet_rpc.create_wallet) }
  end

  describe '#spawn_wallet_proc!' do
    subject(:spawn_wallet_proc!) { cwfs.spawn_wallet_proc!('a', '1') }

    before do
      allow(Process).to receive(:spawn).and_return(1234)
      allow(Process).to receive(:wait2)
    end

    it 'calls spawn on monero-wallet-rpc binary' do
      spawn_wallet_proc!

      expect(Process)
        .to have_received(:spawn).with("monero-wallet-rpc --config-file=wallets/#{wallet.name}.config").once
    end

    it 'enqueues a CreateRpcWalletJob in 30 seconds' do
      spawn_wallet_proc!

      expect(CreateRpcWalletJob).to have_enqueued_sidekiq_job(wallet.id, 'a', '1').in(30.seconds)
    end

    it 'calls wait2 on the newly created pid' do
      spawn_wallet_proc!

      expect(Process).to have_received(:wait2).with(1234).once
    end
  end
end
