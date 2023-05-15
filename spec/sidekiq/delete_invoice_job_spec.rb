# frozen_string_literal: true

RSpec.describe DeleteInvoiceJob, type: :job do
  let(:invoice) { create(:invoice) }

  before do
    allow(Invoice).to receive(:find).and_return(invoice)
    allow(invoice).to receive(:gracefully_delete)
    described_class.new.perform(invoice.id)
  end

  it 'calls invoice.gracefully_delete' do
    expect(invoice).to have_received(:gracefully_delete)
  end
end
