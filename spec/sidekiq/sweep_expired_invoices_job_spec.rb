# frozen_string_literal: true

RSpec.describe SweepExpiredInvoicesJob, type: :job do
  let!(:expired_invoice) { create(:invoice, expires_at: 1.hour.ago) }
  let!(:payable_invoice) { create(:invoice, expires_at: 1.hour.from_now) }

  before do
    described_class.new.perform
  end

  it 'enqueues a DeleteInvoiceJob for the expired invoice' do
    expect(DeleteInvoiceJob).to have_enqueued_sidekiq_job(expired_invoice.id)
  end

  it 'does not enqueue a DeleteInvoiceJob for the payable invoice' do
    expect(DeleteInvoiceJob).not_to have_enqueued_sidekiq_job(payable_invoice.id)
  end
end
