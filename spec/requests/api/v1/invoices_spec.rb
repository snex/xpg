# frozen_string_literal: true

RSpec.describe 'api/v1/invoices' do
  include_context 'when MoneroRpcService is needed'
  include_context 'when MoneroRPC::IncomingTransfer is needed'

  let!(:wallet) { create(:wallet) }
  let(:valid_attributes) do
    {
      wallet_name:  wallet.name,
      amount:       1,
      expires_at:   1.hour.from_now,
      external_id:  'ext_id',
      callback_url: 'https://www.example.test/'
    }
  end
  let(:invalid_attributes) do
    {
      amount: 'lolwut'
    }
  end
  let(:malformed_params) do
    '{{{'
  end

  # TODO: figure out a way to reduce the coupling here
  before do
    allow(rpc).to receive_messages(
      generate_incoming_address: { 'integrated_address' => '1234',
                                   'payment_id'         => '4321' },
      generate_uri:              'hello',
      estimated_confirm_time:    2.minutes
    )
    allow(tx).to receive(:confirmations).and_return(nil, 1, 2)
    allow(tx).to receive(:suggested_confirmations_threshold).and_return(1, 2, 20)
  end

  describe 'GET api/v1/show' do
    context 'when an invalid id is given' do
      it 'renders not_found' do
        get api_v1_invoice_url(0)

        expect(response).to be_not_found
      end
    end

    context 'when a valid id is given' do
      let(:invoice) { create(:invoice, :with_payments) }

      it 'renders the invoice' do
        get api_v1_invoice_url(invoice.id)

        expect(response).to match_response_schema('invoice')
      end
    end
  end

  describe 'POST api/v1/create' do
    context 'with valid parameters' do
      it 'creates a new Invoice' do
        expect do
          post api_v1_invoices_url, params: { invoice: valid_attributes }
        end.to change(Invoice, :count).by(1)
      end

      it 'responds with the created invoice' do
        post api_v1_invoices_url, params: { invoice: valid_attributes }
        expect(response).to match_response_schema('invoice')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Invoice' do
        expect do
          post api_v1_invoices_url, params: { invoice: invalid_attributes }
        end.not_to change(Invoice, :count)
      end

      it 'renders a response with 422 status' do
        post api_v1_invoices_url, params: { invoice: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'renders a response in the correct schema' do
        post api_v1_invoices_url, params: { invoice: invalid_attributes }
        expect(response).to match_response_schema('error')
      end
    end

    context 'with malformed parameters' do
      it 'does not create a new Invoice' do
        expect do
          post api_v1_invoices_url, headers: { 'Content-Type': 'application/json' }, params: malformed_params
        end.not_to change(Invoice, :count)
      end

      it 'renders a response with 422 status' do
        post api_v1_invoices_url, headers: { 'Content-Type': 'application/json' }, params: malformed_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'renders a response in the correct schema' do
        post api_v1_invoices_url, headers: { 'Content-Type': 'application/json' }, params: malformed_params
        expect(response).to match_response_schema('error')
      end
    end
  end
end
