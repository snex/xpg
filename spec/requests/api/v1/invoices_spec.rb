# frozen_string_literal: true

RSpec.describe 'api/v1/invoices' do
  let!(:wallet) { create(:wallet) }
  let(:valid_attributes) do
    {
      wallet_id:    wallet.id,
      amount:       1,
      expires_at:   1.hour.from_now,
      external_id:  'ext_id',
      callback_url: 'https://www.example.test/'
    }
  end
  let(:invalid_attributes) do
    {
      wallet_id: wallet.id,
      amount:    'lolwut'
    }
  end

  describe 'POST api/v1/create' do
    let(:rpc) { instance_double(MoneroRpcService) }

    # TODO: figure out a way to reduce the coupling here
    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:generate_incoming_address).and_return({ 'integrated_address' => '1234',
                                                                     'payment_id'         => '4321' })
      allow(rpc).to receive(:generate_uri).and_return('hello')
      allow(rpc).to receive(:estimated_confirm_time).and_return(2.minutes)
    end

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
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a response in the correct schema' do
        post api_v1_invoices_url, params: { invoice: invalid_attributes }
        expect(response).to match_response_schema('error')
      end
    end
  end
end
