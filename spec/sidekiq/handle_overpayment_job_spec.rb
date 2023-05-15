# frozen_string_literal: true

RSpec.describe HandleOverpaymentJob, type: :job do
  let(:invoice) { create(:invoice) }

  before do
    allow(Invoice).to receive(:find).and_return(invoice)
    described_class.new.perform(invoice.id)
  end

  xit 'sends an email about the overpayment'

  it 'enqueues a HandlePaymentJob' do
    expect(HandlePaymentJob).to have_enqueued_sidekiq_job(invoice.id)
  end
end
