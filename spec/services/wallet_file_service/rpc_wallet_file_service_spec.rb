# frozen_string_literal: true

RSpec.describe WalletFileService::RpcWalletFileService do
  let(:wallet) { create(:wallet) }
  let(:rwfs) { described_class.new(wallet) }

  describe '#config' do
    subject { rwfs.config }

    it { is_expected.to eq(Rails.configuration.monero_wallet_rpc.rpc_wallet) }
  end

  describe '#spawn_wallet_proc!' do
    subject(:spawn_wallet_proc!) { rwfs.spawn_wallet_proc! }

    before do
      allow(Process).to receive(:spawn).and_return(1234)
      allow(Process).to receive(:detach)
    end

    it 'calls spawn on monero-wallet-rpc binary' do
      spawn_wallet_proc!

      expect(Process)
        .to have_received(:spawn).with("monero-wallet-rpc --config-file=wallets/#{wallet.name}.config").once
    end

    it 'sets the wallet pid' do
      expect { spawn_wallet_proc! }.to change(wallet, :pid).from(nil).to(1234)
    end

    it 'calls wait2 on the newly created pid' do
      spawn_wallet_proc!

      expect(Process).to have_received(:detach).with(1234).once
    end
  end
end
