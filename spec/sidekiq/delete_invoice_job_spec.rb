# frozen_string_literal: true

RSpec.describe DeleteInvoiceJob, type: :job do
  let(:invoice) { create(:invoice) }

  before do
    allow(invoice).to receive(:gracefully_delete)
  end

  context 'when the invoice exists' do
    before do
      allow(Invoice).to receive(:find).and_return(invoice)
      described_class.new.perform(invoice.id)
    end

    it 'calls invoice.gracefully_delete' do
      expect(invoice).to have_received(:gracefully_delete)
    end
  end

  context 'when the invoice doesnt exist' do
    before do
      allow(Invoice).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
    end

    it 'does not raise an error' do
      expect { described_class.new.perform(invoice.id) }.not_to raise_error
    end
  end
end
