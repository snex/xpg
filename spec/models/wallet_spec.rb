# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallet do
  let(:wallet) { build(:wallet) }

  describe 'associations' do
    it { is_expected.to have_many(:invoices).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { wallet }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:port) }
    it { is_expected.to validate_uniqueness_of(:port) }
  end

  describe 'after_initialize assign_file_service' do
    context 'when ready_to_run? is true' do
      let!(:wallet) { create(:wallet, ready_to_run: true) }

      it 'instantiates a WalletFileService::RpcWalletFileService' do
        expect(described_class.find(wallet.id).file_service)
          .to be_a(WalletFileService::RpcWalletFileService)
      end
    end

    context 'when ready_to_run? is false' do
      let!(:wallet) { create(:wallet, ready_to_run: false) }

      it 'instantiates a WalletFileService::CreateWalletFileService' do
        expect(described_class.find(wallet.id).file_service)
          .to be_a(WalletFileService::CreateWalletFileService)
      end
    end
  end

  describe 'before_create :generate_rpc_creds' do
    let(:wallet) { build(:wallet, rpc_creds: nil) }

    before { allow(SecureRandom).to receive(:hex).and_return('123', '456') }

    it 'generates RPC credentials' do
      expect { wallet.save }.to change(wallet, :rpc_creds).from(nil).to('123:456')
    end
  end

  describe 'after_commit :create_rpc_wallet_async!' do
    it 'enqueues a SpawnCreateRpcWalletJob for the wallet' do
      wallet.save

      expect(SpawnCreateRpcWalletJob).to have_enqueued_sidekiq_job(wallet.id)
    end
  end

  describe '#create_rpc_wallet!' do
    subject(:create_rpc_wallet!) { wallet.create_rpc_wallet! }

    let(:fs) { instance_double(WalletFileService::CreateWalletFileService) }

    before do
      allow(wallet).to receive(:file_service).and_return(fs)
      allow(fs).to receive(:write_config_file!)
      allow(fs).to receive(:spawn_wallet_proc!)
    end

    context 'when ready_to_run? is true' do
      let(:wallet) { build(:wallet, ready_to_run: true) }

      it 'does not call write_config_file!' do
        create_rpc_wallet!
        expect(fs).not_to have_received(:write_config_file!)
      end

      it 'does not call spawn_wallet_proc!' do
        create_rpc_wallet!
        expect(fs).not_to have_received(:spawn_wallet_proc!)
      end
    end

    context 'when ready_to_run? is false' do
      let(:wallet) { build(:wallet, ready_to_run: false) }

      it 'calls write_config_file!' do
        create_rpc_wallet!
        expect(fs).to have_received(:write_config_file!).once
      end

      it 'calls spawn_create_wallet_proc!' do
        create_rpc_wallet!
        expect(fs).to have_received(:spawn_wallet_proc!).once
      end
    end
  end

  describe '#create_rpc_wallet_file!' do
    subject(:create_rpc_wallet_file!) { wallet.create_rpc_wallet_file! }

    let(:wallet) { build(:wallet, ready_to_run: false) }
    let(:rpc) { instance_double(MoneroRpcService) }

    before do
      allow(MoneroRpcService).to receive(:new).with(wallet).and_return(rpc)
      allow(rpc).to receive(:create_rpc_wallet)
    end

    it 'calls MoneroRpcService.new.create_rpc_wallet for the wallet' do
      create_rpc_wallet_file!

      expect(rpc).to have_received(:create_rpc_wallet).once
    end

    it 'sets ready_to_run to true' do
      expect { create_rpc_wallet_file! }.to change(wallet, :ready_to_run).from(false).to(true)
    end
  end

  describe '#running?' do
    subject { wallet.running? }

    context 'when pid is blank' do
      it { is_expected.to be false }
    end

    context 'when pid is present but no proc running' do
      let(:wallet) { build(:wallet, pid: 1) }

      before { allow(File).to receive(:read).with('/proc/1/cmdline').and_raise(Errno::ENOENT) }

      it { is_expected.to be false }
    end

    context 'when pid is present but the proc has the wrong details' do
      let(:wallet) { build(:wallet, pid: 1) }

      before { allow(File).to receive(:read).with('/proc/1/cmdline').and_return('junk') }

      it { is_expected.to be false }
    end

    context 'when pid is present and proc has the correct details' do
      let(:wallet) { build(:wallet, pid: 1) }

      before do
        allow(File).to receive(:read)
          .with('/proc/1/cmdline')
          .and_return("monero-wallet-rpc --config-file=wallets/#{wallet.name}.config")
      end

      it { is_expected.to be true }
    end
  end

  describe '#run!' do
    subject(:run!) { wallet.run! }

    let(:fs) { instance_double(WalletFileService::RpcWalletFileService) }

    before do
      allow(wallet).to receive(:file_service).and_return(fs)
      allow(fs).to receive(:write_config_file!)
      allow(fs).to receive(:spawn_wallet_proc!)
    end

    context 'when wallet is already running' do
      before { allow(wallet).to receive(:running?).and_return(true) }

      it 'does not call write_config_file!' do
        run!
        expect(fs).not_to have_received(:write_config_file!)
      end

      it 'does not call spawn_wallet_proc!' do
        run!
        expect(fs).not_to have_received(:spawn_wallet_proc!)
      end
    end

    context 'when ready_to_run? is false' do
      let(:wallet) { build(:wallet, ready_to_run: false) }

      it 'does not call write_config_file!' do
        run!
        expect(fs).not_to have_received(:write_config_file!)
      end
    end

    context 'when the wallet is not already running and ready_to_run? is true' do
      let(:wallet) { build(:wallet, ready_to_run: true) }

      before do
        allow(wallet).to receive(:running?).and_return(false)
        run!
      end

      it 'calls write_config_file!' do
        expect(fs).to have_received(:write_config_file!).once
      end

      it 'calls spawn_wallet_proc!' do
        expect(fs).to have_received(:spawn_wallet_proc!).once
      end
    end
  end
end
