# frozen_string_literal: true

RSpec.describe HandlePaymentCompleteJob, type: :job do
  let(:invoice) { create(:invoice) }

  before do
    allow(Invoice).to receive(:find).and_return(invoice)
    allow(invoice).to receive(:handle_payment_complete)
    described_class.new.perform(invoice.id)
  end

  it 'calls invoice.handle_payment_complete' do
    expect(invoice).to have_received(:handle_payment_complete).once
  end
end
