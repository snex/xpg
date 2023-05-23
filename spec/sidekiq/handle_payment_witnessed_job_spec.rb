# frozen_string_literal: true

RSpec.describe HandlePaymentWitnessedJob, type: :job do
  let(:payment) { create(:payment) }

  before do
    allow(Payment).to receive(:find).and_return(payment)
    allow(CallbackService).to receive(:handle_payment_witnessed)
    described_class.new.perform(payment.id)
  end

  it 'calls CallbackService.handle_payment_witnessed' do
    expect(CallbackService).to have_received(:handle_payment_witnessed).with(payment.invoice).once
  end
end
