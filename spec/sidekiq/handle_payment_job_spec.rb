# frozen_string_literal: true

RSpec.describe HandlePaymentJob, type: :job do
  let(:invoice) { create(:invoice) }

  before do
    allow(Invoice).to receive(:find).and_return(invoice)
    allow(invoice).to receive(:callback)
    described_class.new.perform(invoice.id)
  end

  it 'calls invoice.callback' do
    expect(invoice).to have_received(:callback)
  end
end
