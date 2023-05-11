# frozen_string_literal: true

RSpec.describe Invoice do
  let(:invoice) { build(:invoice) }

  describe 'associations' do
    subject { invoice }

    it { is_expected.to belong_to(:wallet) }
    it { is_expected.to have_many(:payments).dependent(:restrict_with_error) }
    it { is_expected.to have_one_attached(:qr_code) }
  end

  describe 'validations' do
    subject { build(:invoice, wallet: wallet) }

    let(:wallet) { build(:wallet) }

    before { allow(wallet).to receive(:generate_incoming_address).and_return('abcd1234') }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:wallet_id) }
    it { is_expected.to validate_presence_of(:callback_url) }
    it { is_expected.to validate_uniqueness_of(:incoming_address).scoped_to(:payment_id) }
    it { is_expected.to validate_url_of(:callback_url) }
  end

  describe 'before_validation :assign_expires_at' do
    context 'when expires_at is already present' do
      it 'accepts the passed in value' do
        expect { invoice.save }.not_to change(invoice, :expires_at)
      end
    end

    context 'when expires_at comes from the wallet' do
      let(:wallet) { create(:wallet, default_expiry_ttl: 30) }
      let(:invoice) { build(:invoice, wallet: wallet, expires_at: nil) }

      before { allow(Time).to receive(:current).and_return(DateTime.new(2000, 1, 1, 0, 0, 0)) }

      it 'uses curren time plus the default value on the wallet, in minutes' do
        expect { invoice.save }.to change(invoice, :expires_at).from(nil).to(DateTime.new(2000, 1, 1, 0, 30, 0))
      end
    end

    context 'when no expires_at is set' do
      let(:wallet) { build(:wallet, default_expiry_ttl: nil) }
      let(:invoice) { build(:invoice, expires_at: nil) }

      it 'cannot save the wallet due to a missing expires_at' do
        expect { invoice.save }.not_to change(invoice, :id)
      end
    end
  end

  describe 'before_create :generate_incoming_address' do
    let(:wallet) { build(:wallet) }
    let(:generated_address) { { 'integrated_address' => '12345', 'payment_id' => '54321' } }

    before { allow(wallet).to receive(:generate_incoming_address).and_return(generated_address) }

    context 'when an incoming_address and pay_mentent_id was provided' do
      let(:invoice) { build(:invoice, wallet: wallet, incoming_address: '54321', payment_id: '12345') }

      it 'does not overwrite the provided address' do
        expect { invoice.save }.not_to change(invoice, :incoming_address)
      end

      it 'does not overwrite the provided payment_id' do
        expect { invoice.save }.not_to change(invoice, :payment_id)
      end
    end

    context 'when an incoming_address and payment_id was not provided' do
      let(:invoice) { build(:invoice, wallet: wallet, incoming_address: nil, payment_id: nil) }

      it 'generates an incoming address from the wallet' do
        expect { invoice.save }.to change(invoice, :incoming_address).from(nil).to('12345')
      end

      it 'generates a payment_id from the wallet' do
        expect { invoice.save }.to change(invoice, :payment_id).from(nil).to('54321')
      end
    end
  end

  describe 'before_create :generate_qr_code' do
    let(:invoice) { build(:invoice) }
    let(:xmr) { instance_double(XMR) }

    before do
      allow(XMR).to receive(:new).and_return(xmr)
      allow(xmr).to receive(:pmt_uri).and_return('hello')
    end

    it 'attaches the QR code to the invoice' do
      invoice.save
      invoice.reload

      expect(invoice.qr_code.checksum).to eq('cFs5MxOcFuS8VKCg80Chvg==')
    end
  end

  describe '#status' do
    subject { invoice.status }

    let(:expires_at) { DateTime.new(2000, 1, 1, 0, 0, 0, '+00:00') }
    let(:invoice) { create(:invoice, amount: 10, expires_at: expires_at) }

    context 'when 1 payment amount exceeds invoice amount' do
      before { create(:payment, invoice: invoice, amount: 11) }

      it { is_expected.to contain_exactly(:overpaid) }
    end

    context 'when the sum of multiple payments exceeds the invoice amount' do
      before { create_list(:payment, 2, invoice: invoice, amount: 6) }

      it { is_expected.to contain_exactly(:overpaid) }
    end

    context 'when 1 payment amount is exactly the invoice amount' do
      before { create(:payment, invoice: invoice, amount: 10) }

      it { is_expected.to contain_exactly(:paid) }
    end

    context 'when the sum of multiple payments is exactly the invoice amount' do
      before { create_list(:payment, 2, invoice: invoice, amount: 5) }

      it { is_expected.to contain_exactly(:paid) }
    end

    context 'when there are no payments and the invoice expires in the future' do
      before { allow(Time).to receive(:current).and_return(expires_at - 1.day) }

      it { is_expected.to contain_exactly(:unpaid, :payable) }
    end

    context 'when there are no payments and the invoice expired' do
      before { allow(Time).to receive(:current).and_return(expires_at + 1.day) }

      it { is_expected.to contain_exactly(:unpaid, :overdue) }
    end

    context 'when 1 payment amount is less than the invoice amount and the invoice expired' do
      before do
        create(:payment, invoice: invoice, amount: 4)
        allow(Time).to receive(:current).and_return(expires_at + 1.day)
      end

      it { is_expected.to contain_exactly(:unpaid, :overdue) }
    end

    context 'when the sum of multiple payments is less than the invoice amount and the invoice expired' do
      before do
        create_list(:payment, 2, invoice: invoice, amount: 4)
        allow(Time).to receive(:current).and_return(expires_at + 1.day)
      end

      it { is_expected.to contain_exactly(:unpaid, :overdue) }
    end
  end
end
