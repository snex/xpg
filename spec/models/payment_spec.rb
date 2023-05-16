# frozen_string_literal: true

RSpec.describe Payment do
  let(:payment) { build(:payment) }

  describe 'associations' do
    it { is_expected.to belong_to(:invoice) }
  end

  describe 'validations' do
    subject { payment }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:monero_tx_id) }
    it { is_expected.to validate_uniqueness_of(:monero_tx_id) }
  end

  describe '#confirmations' do
    subject { payment.confirmations }

    let(:rpc) { instance_double(MoneroRpcService) }
    let(:tx) { instance_double(MoneroRPC::IncomingTransfer) }

    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:transfer_details).and_return(tx)
      allow(tx).to receive(:confirmations).and_return(1234)
    end

    it { is_expected.to eq(1234) }
  end

  describe '#suggested_confirmations_threshold' do
    subject { payment.suggested_confirmations_threshold }

    let(:rpc) { instance_double(MoneroRpcService) }
    let(:tx) { instance_double(MoneroRPC::IncomingTransfer) }

    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:transfer_details).and_return(tx)
      allow(tx).to receive(:suggested_confirmations_threshold).and_return(4321)
    end

    it { is_expected.to eq(4321) }
  end

  describe '#confirmed?' do
    subject { payment.confirmed? }

    let(:rpc) { instance_double(MoneroRpcService) }
    let(:tx) { instance_double(MoneroRPC::IncomingTransfer) }

    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:transfer_details).and_return(tx)
    end

    context 'when the transfer is confirmed' do
      before { allow(tx).to receive(:confirmed?).and_return(true) }

      it { is_expected.to be true }
    end

    context 'when the transfer is not confirmed' do
      before { allow(tx).to receive(:confirmed?).and_return(false) }

      it { is_expected.to be false }
    end
  end

  describe 'after_create_commit :handle_payment_witnessed' do
    it 'enqueues a HandlePaymentWitnessedJob' do
      create(:payment)

      expect(HandlePaymentWitnessedJob).to have_enqueued_sidekiq_job(described_class.first.id)
    end
  end

  describe 'necessary_confirmations' do
    subject { payment.necessary_confirmations }

    let(:rpc) { instance_double(MoneroRpcService) }
    let(:tx) { instance_double(MoneroRPC::IncomingTransfer) }

    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:transfer_details).and_return(tx)
      allow(tx).to receive(:suggested_confirmations_threshold).and_return(confirmations)
    end

    context 'when the suggested_confirmations_threshold is 0' do
      let(:confirmations) { 0 }

      it { is_expected.to eq(1) }
    end

    context 'when the suggested_confirmations_thresdhold is between 1 and 10' do
      let(:confirmations) { rand(1...10) }

      it { is_expected.to eq(confirmations) }
    end

    context 'when the suggested_confirmations_threshold is > 10' do
      let(:confirmations) { rand(11..9_999) }

      it { is_expected.to eq(10) }
    end
  end
end
