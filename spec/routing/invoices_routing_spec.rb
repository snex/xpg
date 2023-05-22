# frozen_string_literal: true

RSpec.describe Api::V1::InvoicesController do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: 'api/v1/invoices/1234').to route_to('api/v1/invoices#show', id: '1234', format: :json)
    end

    it 'routes to #create' do
      expect(post: 'api/v1/invoices').to route_to('api/v1/invoices#create', format: :json)
    end
  end
end
