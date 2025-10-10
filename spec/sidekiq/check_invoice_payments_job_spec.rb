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

    it 'does not enqueue a HandlePaymentCompleteJob' do
      expect(HandlePaymentCompleteJob).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when the invoice is overpaid' do
    before do
      allow(invoice).to receive_messages(unpaid?: false, overpaid?: true)
      described_class.new.perform(invoice.id)
    end

    it 'enqueues a HandleOverpaymentJob' do
      expect(HandleOverpaymentJob).to have_enqueued_sidekiq_job(invoice.id)
    end

    it 'does not enqueue a HandlePaymentCompleteJob' do
      expect(HandlePaymentCompleteJob).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when the invoice is paid exactly' do
    before do
      allow(invoice).to receive_messages(unpaid?: false, overpaid?: false, paid?: true)
      described_class.new.perform(invoice.id)
    end

    it 'does not enqueue a HandleOverpaymentJob' do
      expect(HandleOverpaymentJob).not_to have_enqueued_sidekiq_job
    end

    it 'enqueues a HandlePaymentCompleteJob' do
      expect(HandlePaymentCompleteJob).to have_enqueued_sidekiq_job(invoice.id)
    end
  end
end
