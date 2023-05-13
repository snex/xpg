# frozen_string_literal: true

RSpec.describe WalletsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/wallets').to route_to('wallets#index')
    end

    it 'routes to #new' do
      expect(get: '/wallets/new').to route_to('wallets#new')
    end

    it 'routes to #edit' do
      expect(get: '/wallets/1/edit').to route_to('wallets#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/wallets').to route_to('wallets#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/wallets/1').to route_to('wallets#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/wallets/1').to route_to('wallets#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/wallets/1').to route_to('wallets#destroy', id: '1')
    end

    it 'routes to #status' do
      expect(get: '/wallets/1/status').to route_to('wallets#status', id: '1')
    end
  end
end
