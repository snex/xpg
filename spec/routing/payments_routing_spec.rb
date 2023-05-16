# frozen_string_literal: true

RSpec.describe Api::V1::PaymentsController do
  describe 'routing' do
    it 'routes to #process_transaction' do
      expect(post: 'api/v1/process_transaction').to route_to('api/v1/payments#process_transaction', format: :json)
    end
  end
end
