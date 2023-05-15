# frozen_string_literal: true

RSpec.describe CheckInvoicePaymentsJob, type: :job do
  let(:invoice) { create(:invoice) }

  before { allow(Invoice).to receive(:find).and_return(invoice) }

  context 'when the invoice remains unpaid' do
    before do
      allow(invoice).to receive(:unpaid?).and_return(true)
      described_class.new.perform(invoice.id)
    end

    it 'does not enqueue a HandleOverpaymentJob' do
      expect(HandleOverpaymentJob).not_to have_enqueued_sidekiq_job
    end

    it 'does not enqueue a HandlePaymentJob' do
      expect(HandlePaymentJob).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when the invoice is overpaid' do
    before do
      allow(invoice).to receive(:unpaid?).and_return(false)
      allow(invoice).to receive(:overpaid?).and_return(true)
      described_class.new.perform(invoice.id)
    end

    it 'enqueues a HandleOverpaymentJob' do
      expect(HandleOverpaymentJob).to have_enqueued_sidekiq_job(invoice.id)
    end

    it 'does not enqueue a HandlePaymentJob' do
      expect(HandlePaymentJob).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when the invoice is paid exactly' do
    before do
      allow(invoice).to receive(:unpaid?).and_return(false)
      allow(invoice).to receive(:overpaid?).and_return(false)
      allow(invoice).to receive(:paid?).and_return(true)
      described_class.new.perform(invoice.id)
    end

    it 'does not enqueue a HandleOverpaymentJob' do
      expect(HandleOverpaymentJob).not_to have_enqueued_sidekiq_job
    end

    it 'enqueues a HandlePaymentJob' do
      expect(HandlePaymentJob).to have_enqueued_sidekiq_job(invoice.id)
    end
  end

  context 'when the invoice somehow reaches an impossible state' do
    before do
      allow(invoice).to receive(:unpaid?).and_return(false)
      allow(invoice).to receive(:overpaid?).and_return(false)
      allow(invoice).to receive(:paid?).and_return(false)
    end

    # TODO: replace exception with email
    it 'raises an exception (replace with email)' do
      expect { described_class.new.perform(invoice.id) }.to raise_error(RuntimeError, 'wtf')
    end
  end
end
