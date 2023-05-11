# frozen_string_literal: true

RSpec.describe '/payments' do
  let!(:invoice) { create(:invoice) }
  let(:valid_attributes) do
    {
      wallet_id:    invoice.wallet.id,
      monero_tx_id: '1234'
    }
  end
  let(:attributes) { valid_attributes }

  describe 'POST /process_transaction' do
    before { post process_transaction_url(transaction: attributes) }

    context 'when an invalid wallet_id is given' do
      let(:attributes) { valid_attributes.merge(wallet_id: 0) }

      it 'renders not_found' do
        expect(response).to be_not_found
      end
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end

    it 'enqueues a ProcessTransactionJob' do
      expect(ProcessTransactionJob).to have_enqueued_sidekiq_job(invoice.wallet.id, '1234')
    end
  end
end
