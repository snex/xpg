# frozen_string_literal: true

RSpec.describe CheckInvoicePaymentsJob, type: :job do
  let(:invoice) { create(:invoice) }

  context 'when the invoice remains unpaid' do
    xit 'handle unpaid invoice'
  end

  context 'when the invoice is overpaid' do
    xit 'handle overpaid invoice'
  end

  context 'when the invoice is paid exactly' do
    xit 'handle paid invoice'
  end
end
