# frozen_string_literal: true

RSpec.describe Wallet do
  let(:wallet) { build(:wallet) }

  describe 'associations' do
    it { is_expected.to have_many(:invoices).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { wallet }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to allow_value('wallet-1_foo').for(:name) }
    it { is_expected.not_to allow_value('2wallet').for(:name).with_message(I18n.t('wallet.name_format_error')) }
    it { is_expected.not_to allow_value('wallet&').for(:name).with_message(I18n.t('wallet.name_format_error')) }
    it { is_expected.to validate_presence_of(:port) }
    it { is_expected.to validate_uniqueness_of(:port) }
    it { is_expected.to validate_numericality_of(:default_expiry_ttl).only_integer.allow_nil }
  end

  describe 'before_validation :generate_creds' do
    let(:wallet) { build(:wallet, password: nil, rpc_creds: nil) }

    before { allow(SecureRandom).to receive(:hex).and_return('123', '456', '789') }

    it 'generates a password' do
      expect { wallet.valid? }.to change(wallet, :password).from(nil).to('123')
    end

    it 'generates RPC credentials' do
      expect { wallet.valid? }.to change(wallet, :rpc_creds).from(nil).to('456:789')
    end
  end

  describe '#create_rpc_wallet!' do
    subject(:create_rpc_wallet!) { wallet.create_rpc_wallet!('a', '1') }

    let(:fs) { instance_double(WalletFileService::CreateWalletFileService) }

    before do
      allow(WalletFileService::CreateWalletFileService).to receive(:new).and_return(fs)
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
    subject(:create_rpc_wallet_file!) { wallet.create_rpc_wallet_file!('a', '1') }

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

  describe '#transfer_details' do
    subject(:transfer_details) { wallet.transfer_details('1234') }

    let(:rpc) { instance_double(MoneroRpcService) }

    before { allow(MoneroRpcService).to receive(:new).with(wallet).and_return(rpc) }

    context 'when RPC creds have not been generated' do
      let(:wallet) { build(:wallet, rpc_creds: nil) }

      it 'does not call MonerpRpcService.new' do
        transfer_details

        expect(MoneroRpcService).not_to have_received(:new)
      end

      it { is_expected.to be_nil }
    end

    context 'when RPC creds have been generated' do
      before { allow(rpc).to receive(:transfer_details).and_return('12345') }

      it 'calls MoneroRpcService.new' do
        transfer_details

        expect(MoneroRpcService).to have_received(:new).once
      end

      it 'calls transfer_details' do
        transfer_details

        expect(rpc).to have_received(:transfer_details).once
      end

      it { is_expected.to eq('12345') }
    end
  end

  describe '#process_transaction' do
    subject(:process_tx) { wallet.process_transaction('abcd') }

    let(:rpc) { instance_double(MoneroRpcService) }
    let(:tx_in) { instance_double(MoneroRPC::IncomingTransfer) }

    before do
      allow(MoneroRpcService).to receive(:new).with(wallet).and_return(rpc)
      allow(rpc).to receive(:transfer_details).and_return(tx_in)
      allow(tx_in).to receive(:payment_id).and_return('1234')
      allow(tx_in).to receive(:amount).and_return(1)
    end

    context 'when the transaction has already been processed' do
      before { allow(Payment).to receive(:exists?).and_return(true) }

      it 'does not call the RPC service' do
        process_tx

        expect(rpc).not_to have_received(:transfer_details)
      end
    end

    context 'when there is no invoice expecting a transaction' do
      before do
        allow(wallet).to receive(:invoices).and_return(Invoice.none)
        allow(wallet).to receive(:handle_invoiceless_payment)
      end

      it 'calls handle_invoiceless_payment' do
        process_tx

        expect(wallet).to have_received(:handle_invoiceless_payment).with(tx_in).once
      end

      it 'does not create a Payment' do
        expect { process_tx }.not_to change(Payment, :count)
      end
    end

    context 'when there is no invoice with the incoming payment_id' do
      before do
        create(:invoice, wallet: wallet, payment_id: '4321')
        allow(wallet).to receive(:handle_invoiceless_payment)
      end

      it 'calls handle_invoiceless_payment' do
        process_tx

        expect(wallet).to have_received(:handle_invoiceless_payment).with(tx_in).once
      end

      it 'does not create a Payment' do
        expect { process_tx }.not_to change(Payment, :count)
      end
    end

    context 'when there is an invoice with the incoming payment_id' do
      before do
        create(:invoice, wallet: wallet, payment_id: '1234')
        allow(tx_in).to receive(:confirmations).and_return(nil)
        allow(tx_in).to receive(:suggested_confirmations_threshold).and_return(2)
      end

      it 'creates a Payment' do
        expect { process_tx }.to change(Payment, :count).by(1)
      end

      it 'enqueues a HandlePaymentWitnessedJob' do
        process_tx

        expect(HandlePaymentWitnessedJob).to have_enqueued_sidekiq_job(Payment.first.id)
      end
    end
  end

  describe '#handle_invoiceless_payment' do
    subject(:handle_invoiceless_payment) { wallet.handle_invoiceless_payment(tx_in) }

    let(:rpc) { instance_double(MoneroRpcService) }
    let(:tx_in) { instance_double(MoneroRPC::IncomingTransfer) }

    before do
      allow(MoneroRpcService).to receive(:new).with(wallet).and_return(rpc)
      allow(rpc).to receive(:transfer_details).and_return(tx_in)
      allow(tx_in).to receive(:address).and_return('1234')
      allow(tx_in).to receive(:payment_id).and_return('5678')
      allow(tx_in).to receive(:amount).and_return(1)
    end

    context 'when mail is disabled' do
      before { allow(MailConfig).to receive(:enabled?).and_return(false) }

      it 'does not send an email' do
        expect { handle_invoiceless_payment }.not_to change(WalletMailer.deliveries, :count)
      end
    end

    context 'when mail is enabled' do
      before { allow(MailConfig).to receive(:enabled?).and_return(true) }

      it 'sends an email' do
        expect { handle_invoiceless_payment }.to change(WalletMailer.deliveries, :count).from(0).to(1)
      end
    end
  end

  describe '#status' do
    subject { wallet.status }

    context 'when the wallet is running' do
      before { allow(wallet).to receive(:running?).and_return(true) }

      it { is_expected.to eq(:running) }
    end

    context 'when the wallet is currently being built' do
      before do
        allow(wallet).to receive(:running?).and_return(false)
        allow(wallet).to receive(:ready_to_run?).and_return(false)
      end

      it { is_expected.to eq(:building) }
    end

    context 'when anything else happens' do
      before do
        allow(wallet).to receive(:running?).and_return(false)
        allow(wallet).to receive(:ready_to_run?).and_return(true)
      end

      it { is_expected.to eq(:error) }
    end
  end

  describe '#running?' do
    subject(:running?) { wallet.running? }

    context 'when pid is blank' do
      it { is_expected.to be false }
    end

    context 'when pid is present but no proc running' do
      let(:wallet) { build(:wallet, pid: 1) }

      before { allow(File).to receive(:read).with('/proc/1/cmdline').and_raise(Errno::ENOENT) }

      it { is_expected.to be false }

      it 'updates pid to nil' do
        expect { running? }.to change(wallet, :pid).from(1).to(nil)
      end
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
      allow(WalletFileService::RpcWalletFileService).to receive(:new).and_return(fs)
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
