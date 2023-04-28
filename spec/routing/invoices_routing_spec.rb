# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/invoices').to route_to('invoices#index', format: :json)
    end

    it 'routes to #show' do
      expect(get: '/invoices/1').to route_to('invoices#show', id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/invoices').to route_to('invoices#create', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/invoices/1').to route_to('invoices#update', id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/invoices/1').to route_to('invoices#update', id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/invoices/1').to route_to('invoices#destroy', id: '1', format: :json)
    end
  end
end
