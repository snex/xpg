# frozen_string_literal: true

RSpec.describe CheckPaymentConfirmationsJob, type: :job do
  let(:payment) { create(:payment) }

  before { allow(Payment).to receive(:find_by).and_return(payment) }

  context 'when the payment has already been deleted' do
    before do
      allow(Payment).to receive(:find_by).and_return(nil)
      described_class.new.perform(payment.id)
    end

    it 'does not enqueue a CheckInvoicePaymentsJob' do
      expect(CheckInvoicePaymentsJob).not_to have_enqueued_sidekiq_job(payment.invoice.id)
    end

    it 'does not enqueue itself' do
      expect(described_class).not_to have_enqueued_sidekiq_job(payment.id).in(30.seconds)
    end
  end

  context 'when the payment has been confirmed' do
    before { allow(payment).to receive(:confirmed?).and_return(true) }

    it 'queues a job for the invoice to check for total completion' do
      described_class.new.perform(payment.id)

      expect(CheckInvoicePaymentsJob).to have_enqueued_sidekiq_job(payment.invoice.id)
    end
  end

  context 'when the payment has not been confirmed' do
    before { allow(payment).to receive(:confirmed?).and_return(false) }

    it 'queues itself to check again in 30 seconds' do
      described_class.new.perform(payment.id)

      expect(described_class).to have_enqueued_sidekiq_job(payment.id).in(30.seconds)
    end
  end
end
