# frozen_string_literal: true

RSpec.describe Admin::WalletsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/wallets').to route_to('admin/wallets#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/wallets/new').to route_to('admin/wallets#new')
    end

    it 'routes to #edit' do
      expect(get: '/admin/wallets/1/edit').to route_to('admin/wallets#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/wallets').to route_to('admin/wallets#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/wallets/1').to route_to('admin/wallets#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/wallets/1').to route_to('admin/wallets#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/wallets/1').to route_to('admin/wallets#destroy', id: '1')
    end

    it 'routes to #status' do
      expect(get: '/admin/wallets/1/status').to route_to('admin/wallets#status', id: '1')
    end
  end
end
