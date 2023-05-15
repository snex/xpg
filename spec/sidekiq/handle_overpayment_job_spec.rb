# frozen_string_literal: true

RSpec.describe HandleOverpaymentJob, type: :job do
  let(:invoice) { create(:invoice) }

  before do
    allow(Invoice).to receive(:find).and_return(invoice)
    allow(invoice).to receive(:handle_overpayment)
    described_class.new.perform(invoice.id)
  end

  it 'calls invoice.handle_overpayment' do
    expect(invoice).to have_received(:handle_overpayment)
  end
end
