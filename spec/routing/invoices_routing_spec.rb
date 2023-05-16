# frozen_string_literal: true

RSpec.describe Api::V1::InvoicesController do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: 'api/v1/invoices').to route_to('api/v1/invoices#create', format: :json)
    end
  end
end
