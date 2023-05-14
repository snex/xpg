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
end
