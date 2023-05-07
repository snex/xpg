# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/invoices' do
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
    { wallet_id: '', external_id: '' }
  end

  before { allow(wallet).to receive(:generate_incoming_address).and_return('1234') }

  describe 'GET /index' do
    before do
      create_list(:invoice, 2, wallet: wallet)
      get invoices_url
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end

    it 'renders a response in the correct schema' do
      expect(response).to match_response_schema('invoices')
    end
  end

  describe 'GET /show' do
    let(:invoice) { create(:invoice, wallet: wallet) }

    before do
      get invoice_url(invoice)
    end

    it 'renders a successful response' do
      expect(response).to be_successful
    end

    it 'renders a response in the correct schema' do
      expect(response).to match_response_schema('invoice')
    end
  end

  describe 'POST /create' do
    let(:rpc) { instance_double(MoneroRpcService) }

    # TODO: figure out a way to reduce the coupling here
    before do
      allow(MoneroRpcService).to receive(:new).and_return(rpc)
      allow(rpc).to receive(:create_incoming_address).and_return('1234')
    end

    context 'with valid parameters' do
      it 'creates a new Invoice' do
        expect do
          post invoices_url, params: { invoice: valid_attributes }
        end.to change(Invoice, :count).by(1)
      end

      it 'responds with the created invoice' do
        post invoices_url, params: { invoice: valid_attributes }
        expect(response).to match_response_schema('invoice')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Invoice' do
        expect do
          post invoices_url, params: { invoice: invalid_attributes }
        end.not_to change(Invoice, :count)
      end

      it 'renders a response with 422 status' do
        post invoices_url, params: { invoice: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    let(:invoice) { create(:invoice, wallet: wallet) }

    context 'with valid parameters' do
      let(:new_attributes) do
        { amount: 20 }
      end

      it 'updates the requested invoice' do
        patch invoice_url(invoice), params: { invoice: new_attributes }
        invoice.reload
        expect(invoice.amount).to eq('20')
      end

      it 'renders the updated invoice' do
        patch invoice_url(invoice), params: { invoice: new_attributes }
        invoice.reload
        expect(response).to match_response_schema('invoice')
      end
    end

    context 'with invalid parameters' do
      it 'renders a response with 422 status' do
        patch invoice_url(invoice), params: { invoice: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    let!(:invoice) { create(:invoice, wallet: wallet) }

    it 'destroys the requested invoice' do
      expect do
        delete invoice_url(invoice)
      end.to change(Invoice, :count).by(-1)
    end

    it 'redirects to the invoices list' do
      delete invoice_url(invoice)
      expect(response).to have_http_status(:no_content)
    end
  end
end
