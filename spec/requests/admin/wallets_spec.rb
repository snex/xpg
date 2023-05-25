# frozen_string_literal: true

RSpec.describe '/admin/wallets' do
  let(:valid_attributes) do
    { address: 'a', view_key: '1', name: 'wallet', port: 1 }
  end
  let(:invalid_attributes) do
    { name: '' }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get admin_wallets_url
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_admin_wallet_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    let(:wallet) { create(:wallet) }

    it 'renders a successful response' do
      get edit_admin_wallet_url(wallet)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Wallet' do
        expect do
          post admin_wallets_url, params: { wallet: valid_attributes }
        end.to change(Wallet, :count).by(1)
      end

      it 'redirects to the created wallet' do
        post admin_wallets_url, params: { wallet: valid_attributes }
        expect(response).to redirect_to(admin_wallets_url)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Wallet' do
        expect do
          post admin_wallets_url, params: { wallet: invalid_attributes }
        end.not_to change(Wallet, :count)
      end

      it 'renders a response with 422 status' do
        post admin_wallets_url, params: { wallet: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /update' do
    let(:wallet) { create(:wallet) }

    context 'with valid parameters' do
      let(:new_attributes) do
        { name: 'wallet2' }
      end

      it 'updates the requested wallet' do
        patch admin_wallet_url(wallet), params: { wallet: new_attributes }
        wallet.reload
        expect(wallet.name).to eq('wallet2')
      end

      it 'redirects to the wallet' do
        patch admin_wallet_url(wallet), params: { wallet: new_attributes }
        wallet.reload
        expect(response).to redirect_to(admin_wallets_url)
      end
    end

    context 'with invalid parameters' do
      it 'renders a response with 422 status' do
        patch admin_wallet_url(wallet), params: { wallet: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    let!(:wallet) { create(:wallet) }

    it 'destroys the requested wallet' do
      expect do
        delete admin_wallet_url(wallet)
      end.to change(Wallet, :count).by(-1)
    end

    it 'redirects to the wallets list' do
      delete admin_wallet_url(wallet)
      expect(response).to redirect_to(admin_wallets_url)
    end
  end

  describe 'GET /wallet/:id/status' do
    let(:wallet) { create(:wallet) }

    it 'renders a successful response' do
      get status_admin_wallet_url(wallet)
      expect(response).to be_successful
    end
  end
end
