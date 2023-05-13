# frozen_string_literal: true

RSpec.describe InvoicesController do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/invoices').to route_to('invoices#create', format: :json)
    end
  end
end
