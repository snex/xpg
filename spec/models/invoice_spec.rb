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

    context 'when the invoice does not have a wallet_id' do
      let(:invoice) { build(:invoice, expires_at: nil, wallet_id: nil) }

      it 'does nothing' do
        expect { invoice.valid? }.not_to change(invoice, :expires_at)
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
    include_context 'when MoneroRpcService is needed'

    let(:generated_address) { { 'integrated_address' => '12345', 'payment_id' => '54321' } }

    before { allow(rpc).to receive(:generate_incoming_address).and_return(generated_address) }

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
    include_context 'when MoneroRpcService is needed'

    before { allow(rpc).to receive(:generate_uri).and_return('hello') }

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

    include_context 'when MoneroRpcService is needed'

    before { allow(rpc).to receive(:estimated_confirm_time) }

    it 'calls the MoneroRpcService' do
      estimated_confirm_time

      expect(rpc).to have_received(:estimated_confirm_time).with(invoice.amount.to_i).once
    end
  end

  describe '#amount_paid' do
    subject { invoice.amount_paid }

    let!(:confirmed) { create_list(:payment, 2, invoice: invoice) }
    let!(:unconfirmed) { create_list(:payment, 2, invoice: invoice) }

    before do
      allow(invoice).to receive(:payments).and_return(confirmed + unconfirmed)
      confirmed.each { |c| allow(c).to receive(:confirmed?).and_return(true) }
      unconfirmed.each { |u| allow(u).to receive(:confirmed?).and_return(false) }
    end

    it { is_expected.to eq(confirmed[0].amount.to_i + confirmed[1].amount.to_i) }
  end

  describe '#paid?' do
    subject { invoice.paid? }

    let(:invoice) { build(:invoice, amount: 2) }

    before { allow(invoice).to receive(:amount_paid).and_return(amt) }

    context 'when the confirmed payments < the invoice amount' do
      let(:amt) { 1 }

      it { is_expected.to be false }
    end

    context 'when the confirmed payments = the invoice amount' do
      let(:amt) { 2 }

      it { is_expected.to be true }
    end

    context 'when the confirmed payments > the invoice amount' do
      let(:amt) { 3 }

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

    before { allow(invoice).to receive(:amount_paid).and_return(amt) }

    context 'when the confirmed payments < the invoice amount' do
      let(:amt) { 1 }

      it { is_expected.to be false }
    end

    context 'when the confirmed payments = the invoice amount' do
      let(:amt) { 2 }

      it { is_expected.to be false }
    end

    context 'when the confirmed payments > the invoice amount' do
      let(:amt) { 3 }

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

  describe '#payments_witnessed' do
    subject { invoice.payments_witnessed }

    let!(:payments) do
      [
        create(:payment, invoice: invoice, amount: 7),
        create(:payment, invoice: invoice, amount: 8)
      ]
    end
    let(:ar) { Payment.none }
    let(:expected) do
      [
        { amount: 7, confirmations: 1, necessary_confirmations: 2 },
        { amount: 8, confirmations: 3, necessary_confirmations: 4 }
      ]
    end

    before do
      allow(payments[0]).to receive(:confirmations).and_return(1)
      allow(payments[0]).to receive(:necessary_confirmations).and_return(2)
      allow(payments[1]).to receive(:confirmations).and_return(3)
      allow(payments[1]).to receive(:necessary_confirmations).and_return(4)
      allow(invoice).to receive(:payments).and_return(ar)
      allow(ar).to receive(:order).and_return(payments)
    end

    it { is_expected.to eq(expected) }
  end

  describe '#handle_payment_complete' do
    subject(:handle_payment_complete) { invoice.handle_payment_complete }

    before { allow(CallbackService).to receive(:handle_payment_complete) }

    it 'calls CallbackService.handle_payment_complete' do
      handle_payment_complete

      expect(CallbackService).to have_received(:handle_payment_complete).with(invoice.callback_url).once
    end
  end

  describe '#handle_overpayment' do
    subject(:handle_overpayment) { invoice.handle_overpayment }

    let(:invoice) { create(:invoice) }

    context 'when mail is disabled' do
      before { allow(MailConfig).to receive(:enabled?).and_return(false) }

      it 'does not send an email' do
        expect { handle_overpayment }.not_to change(InvoiceMailer.deliveries, :count)
      end
    end

    context 'when mail is enabled' do
      before { allow(MailConfig).to receive(:enabled?).and_return(true) }

      it 'sends an email about overpayment' do
        expect { handle_overpayment }.to change(InvoiceMailer.deliveries, :count).from(0).to(1)
      end
    end

    it 'enqueues a HandlePaymentCompleteJob' do
      handle_overpayment

      expect(HandlePaymentCompleteJob).to have_enqueued_sidekiq_job(invoice.id)
    end
  end

  describe '#handle_partial_payment' do
    subject(:handle_partial_payment) { invoice.handle_partial_payment }

    let(:invoice) { create(:invoice) }

    context 'when mail is disabled' do
      before { allow(MailConfig).to receive(:enabled?).and_return(false) }

      it 'sends an email about partial payment' do
        expect { handle_partial_payment }.not_to change(InvoiceMailer.deliveries, :count)
      end
    end

    context 'when mail is enabled' do
      before { allow(MailConfig).to receive(:enabled?).and_return(true) }

      it 'sends an email about partial payment' do
        expect { handle_partial_payment }.to change(InvoiceMailer.deliveries, :count).from(0).to(1)
      end
    end

    it 'enqueues a DeleteInvoiceJob' do
      handle_partial_payment

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

    context 'when the invoice is paid and the skip_delete_paid override is true' do
      before do
        allow(invoice).to receive(:paid_unconfirmed?).and_return(false)
        allow(invoice).to receive(:paid?).and_return(true)
      end

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

    context 'when the invoice is paid and the skip_delete_paid override is false' do
      subject(:gracefully_delete) { invoice.gracefully_delete(skip_delete_paid: false) }

      before do
        allow(invoice).to receive(:paid_unconfirmed?).and_return(false)
        allow(invoice).to receive(:paid?).and_return(true)
      end

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

    context 'when the invoice is partially paid' do
      before do
        allow(invoice).to receive(:partially_paid?).and_return(true)
        allow(invoice).to receive(:paid?).and_return(false)
      end

      it 'calls handle_partial_payment' do
        gracefully_delete

        expect(invoice).to have_received(:handle_partial_payment).once
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
      before do
        allow(invoice).to receive(:partially_paid?).and_return(false)
        allow(invoice).to receive(:paid?).and_return(false)
      end

      it 'does not call handle_partial_payment' do
        gracefully_delete

        expect(invoice).not_to have_received(:handle_partial_payment)
      end

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
