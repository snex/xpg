# frozen_string_literal: true

RSpec.describe InvoiceCreator do
  it 'includes ActiveModel::Model' do
    expect(described_class.ancestors).to include(ActiveModel::Model)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:wallet_name) }
  end

  describe '#validate_invoice' do
    subject(:valid?) { ic.valid? }

    let!(:ic) { described_class.new(wallet_name: wallet.name, amount: 1, expires_at: 1.hour.from_now, callback_url: 'http://www.google.com', external_id: '1234') }
    let!(:wallet) { create(:wallet) }

    context 'when the invoice is valid' do
      it { is_expected.to be true }
    end

    context 'when the invoice is invalid' do
      let!(:ic) { described_class.new }

      it { is_expected.to be false }

      it 'populates errors' do
        valid?

        expect(ic.errors).not_to be_empty
      end
    end
  end

  describe 'delegators' do
    it { is_expected.to delegate_method(:to_param).to(:invoice) }
  end

  describe '.model_name' do
    subject { described_class.model_name }

    it { is_expected.to eq(Invoice.model_name) }
  end

  describe '#save' do
    subject(:save) { ic.save }

    let!(:wallet) { create(:wallet) }
    let!(:ic) { described_class.new(wallet_name: wallet.name, amount: 1, expires_at: 1.hour.from_now, callback_url: 'http://www.google.com', external_id: '1234') }
    let!(:invoice) { build(:invoice) }

    before do
      allow(ic).to receive(:invoice).and_return(invoice)
      allow(invoice).to receive(:save!).and_call_original
    end

    context 'when InvoiceCreator is invalid' do
      before { allow(ic).to receive(:invalid?).and_return(true) }

      it { is_expected.to be_nil }

      it 'does not call invoice.save!' do
        save

        expect(invoice).not_to have_received(:save!)
      end
    end

    context 'when InvoiceCreator is valid' do
      before { allow(ic).to receive(:invalid?).and_return(false) }

      it 'calls invoice.save!' do
        save

        expect(invoice).to have_received(:save!).once
      end
    end
  end
end
