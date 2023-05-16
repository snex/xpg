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
    subject { create(:invoice) }

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
      let(:wallet) { create(:wallet, default_expiry_ttl: nil) }
      let(:invoice) { build(:invoice, wallet: wallet, expires_at: nil) }

      it 'cannot save the wallet due to a missing expires_at' do
        expect { invoice.save }.not_to change(invoice, :id)
      end
    end
  end

  describe 'before_create :generate_incoming_address' do
    let(:rpc) { instance_double(MoneroRpcService) }
    let(:generated_address) { { 'integrated_address' => '12345', 'payment_id' => '54321' } }

    before do
      allow(invoice).to receive(:monero_rpc_service).and_return(rpc)
      allow(rpc).to receive(:generate_incoming_address).and_return(generated_address)
    end

    context 'when an incoming_address and pay_mentent_id was provided' do
      let(:invoice) { build(:invoice, incoming_address: '54321', payment_id: '12345') }

      it 'does not overwrite the provided address' do
        expect { invoice.save }.not_to change(invoice, :incoming_address)
      end

      it 'does not overwrite the provided payment_id' do
        expect { invoice.save }.not_to change(invoice, :payment_id)
      end
    end

    context 'when an incoming_address and payment_id was not provided' do
      let(:invoice) { build(:invoice, incoming_address: nil, payment_id: nil) }

      it 'generates an incoming address from the wallet' do
        expect { invoice.save }.to change(invoice, :incoming_address).from(nil).to('12345')
      end

      it 'generates a payment_id from the wallet' do
        expect { invoice.save }.to change(invoice, :payment_id).from(nil).to('54321')
      end
    end
  end

  describe 'before_create :generate_qr_code' do
    let(:rpc) { instance_double(MoneroRpcService) }

    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:generate_uri).and_return('hello')
    end

    context 'when a QR code is already attached' do
      it 'does not overwrite the provided QR code' do
        expect { invoice.save }.not_to change(invoice, :qr_code)
      end
    end

    context 'when no QR code is attached' do
      let(:invoice) { build(:invoice, qr_code: nil) }

      it 'attaches the QR code to the invoice' do
        invoice.save
        invoice.reload

        expect(invoice.qr_code.checksum).to eq('cFs5MxOcFuS8VKCg80Chvg==')
      end
    end
  end

  describe 'scope :expired' do
    subject { described_class.expired }

    let!(:expired) { create(:invoice, expires_at: 1.hour.ago) }

    before { create(:invoice, expires_at: 1.hour.from_now) }

    it { is_expected.to contain_exactly(expired) }
  end

  describe '#estimated_confirm_time' do
    subject(:estimated_confirm_time) { invoice.estimated_confirm_time }

    let(:rpc) { instance_double(MoneroRpcService) }

    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:estimated_confirm_time)
    end

    it 'calls the MoneroRpcService' do
      estimated_confirm_time

      expect(rpc).to have_received(:estimated_confirm_time).with(invoice.amount.to_i).once
    end
  end

  describe '#paid?' do
    subject { invoice.paid? }

    let(:invoice) { build(:invoice, amount: 2) }
    let!(:payments) { create_list(:payment, 3, invoice: invoice, amount: 1) }

    before { allow(invoice).to receive(:payments).and_return(payments) }

    context 'when the confirmed payments < the invoice amount' do
      before do
        allow(payments[0]).to receive(:confirmed?).and_return(true)
        allow(payments[1]).to receive(:confirmed?).and_return(false)
        allow(payments[2]).to receive(:confirmed?).and_return(false)
      end

      it { is_expected.to be false }
    end

    context 'when the confirmed payments = the invoice amount' do
      before do
        allow(payments[0]).to receive(:confirmed?).and_return(true)
        allow(payments[1]).to receive(:confirmed?).and_return(true)
        allow(payments[2]).to receive(:confirmed?).and_return(false)
      end

      it { is_expected.to be true }
    end

    context 'when the confirmed payments > the invoice amount' do
      before do
        allow(payments[0]).to receive(:confirmed?).and_return(true)
        allow(payments[1]).to receive(:confirmed?).and_return(true)
        allow(payments[2]).to receive(:confirmed?).and_return(true)
      end

      it { is_expected.to be true }
    end
  end

  describe '#unpaid?' do
    subject { invoice.unpaid? }

    context 'when the invoice is paid' do
      before { allow(invoice).to receive(:paid?).and_return(true) }

      it { is_expected.to be false }
    end

    context 'when the invoice is unpaid' do
      before { allow(invoice).to receive(:paid?).and_return(false) }

      it { is_expected.to be true }
    end
  end

  describe '#paid_unconfirmed?' do
    subject { invoice.paid_unconfirmed? }

    let(:invoice) { build(:invoice, amount: 3) }

    context 'when the payments < the invoice amount' do
      before { create_list(:payment, 2, invoice: invoice, amount: 1) }

      it { is_expected.to be false }
    end

    context 'when the payments => the invoice amount the invoice is considered unpaid' do
      before do
        create_list(:payment, 3, invoice: invoice, amount: 1)
        allow(invoice).to receive(:unpaid?).and_return(true)
      end

      it { is_expected.to be true }
    end

    context 'when the payments => the invoice amount and the invoice is considererd paid' do
      before do
        create_list(:payment, 3, invoice: invoice, amount: 1)
        allow(invoice).to receive(:unpaid?).and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  describe '#overpaid?' do
    subject { invoice.overpaid? }

    let(:invoice) { build(:invoice, amount: 2) }
    let!(:payments) { create_list(:payment, 3, invoice: invoice, amount: 1) }

    before { allow(invoice).to receive(:payments).and_return(payments) }

    context 'when the confirmed payments < the invoice amount' do
      before do
        allow(payments[0]).to receive(:confirmed?).and_return(true)
        allow(payments[1]).to receive(:confirmed?).and_return(false)
        allow(payments[2]).to receive(:confirmed?).and_return(false)
      end

      it { is_expected.to be false }
    end

    context 'when the confirmed payments = the invoice amount' do
      before do
        allow(payments[0]).to receive(:confirmed?).and_return(true)
        allow(payments[1]).to receive(:confirmed?).and_return(true)
        allow(payments[2]).to receive(:confirmed?).and_return(false)
      end

      it { is_expected.to be false }
    end

    context 'when the confirmed payments > the invoice amount' do
      before do
        allow(payments[0]).to receive(:confirmed?).and_return(true)
        allow(payments[1]).to receive(:confirmed?).and_return(true)
        allow(payments[2]).to receive(:confirmed?).and_return(true)
      end

      it { is_expected.to be true }
    end
  end

  describe '#partially_paid?' do
    subject { invoice.partially_paid? }

    context 'when invoice is paid' do
      before { allow(invoice).to receive(:paid?).and_return(true) }

      it { is_expected.to be false }
    end

    context 'when invoice is not paid and amount_paid = 0' do
      before do
        allow(invoice).to receive(:paid?).and_return(false)
        allow(invoice).to receive(:amount_paid).and_return(0)
      end

      it { is_expected.to be false }
    end

    context 'when invoice is not paid and amount_paid > 0' do
      before do
        allow(invoice).to receive(:paid?).and_return(false)
        allow(invoice).to receive(:amount_paid).and_return(1)
      end

      it { is_expected.to be true }
    end
  end

  describe '#handle_payment_complete' do
    subject(:handle_payment_complete) { invoice.handle_payment_complete }

    before do
      allow(URI).to receive(:parse)
      allow(Net::HTTP).to receive(:get)
      handle_payment_complete
    end

    it 'calls URI.parse' do
      expect(URI).to have_received(:parse).with(invoice.callback_url)
    end

    it 'calls Net::HTTP.get' do
      expect(Net::HTTP).to have_received(:get).with(URI.parse(invoice.callback_url))
    end
  end

  describe '#handle_overpayment' do
    subject(:handle_overpayment) { invoice.handle_overpayment }

    let(:invoice) { create(:invoice) }

    before { handle_overpayment }

    xit 'sends an email about overpayment'

    it 'enqueues a HandlePaymentJob' do
      expect(HandlePaymentJob).to have_enqueued_sidekiq_job(invoice.id)
    end
  end

  describe '#handle_partial_payment' do
    subject(:handle_partial_payment) { invoice.handle_partial_payment }

    let(:invoice) { create(:invoice) }

    before { handle_partial_payment }

    xit 'send an email about partial payment on an invoice queued for deletion'

    it 'enqueues a DeleteInvoiceJob' do
      expect(DeleteInvoiceJob).to have_enqueued_sidekiq_job(invoice.id)
    end
  end

  describe '#gracefully_delete' do
    subject(:gracefully_delete) { invoice.gracefully_delete }

    let(:qr_code) { invoice.qr_code }
    let!(:invoice) { create(:invoice, :with_payments) }

    before do
      allow(invoice).to receive(:handle_partial_payment)
      allow(invoice).to receive(:paid_unconfirmed?).and_return(false)
    end

    context 'when the invoice is paid but payments are unconfirmed' do
      before { allow(invoice).to receive(:paid_unconfirmed?).and_return(true) }

      it 'does not destroy the payments' do
        expect { gracefully_delete }.not_to change(Payment, :count)
      end

      it 'does not remove the qr code' do
        expect { gracefully_delete }.not_to change(qr_code, :reload)
      end

      it 'does not destroy the invoice' do
        expect { gracefully_delete }.not_to change(described_class, :count)
      end
    end

    context 'when the invoice is partially paid' do
      before { allow(invoice).to receive(:partially_paid?).and_return(true) }

      it 'calls handle_partial_payment' do
        gracefully_delete

        expect(invoice).to have_received(:handle_partial_payment)
      end

      it 'destroys the payments' do
        expect { gracefully_delete }.to change(Payment, :count).from(3).to(0)
      end

      it 'does not remove the qr code' do
        expect { gracefully_delete }.not_to change(qr_code, :reload)
      end

      it 'does not destroy the invoice' do
        expect { gracefully_delete }.not_to change(described_class, :count)
      end
    end

    context 'when the invoice is not partially paid' do
      before { allow(invoice).to receive(:partially_paid?).and_return(false) }

      it 'does not call handle_partial_payment' do
        gracefully_delete

        expect(invoice).not_to have_received(:handle_partial_payment)
      end

      xit 'deletes the invoice, any associated payments, and attached qr codes'

      it 'destroys the payments' do
        expect { gracefully_delete }.to change(Payment, :count).from(3).to(0)
      end

      it 'removes the qr code' do
        expect { gracefully_delete }.to change(qr_code, :reload).to(nil)
      end

      it 'destroys the invoice' do
        expect { gracefully_delete }.to change(described_class, :count).from(1).to(0)
      end
    end
  end
end
