# frozen_string_literal: true

RSpec.describe PaymentsController do
  describe 'routing' do
    it 'routes to #process_transaction' do
      expect(post: '/process_transaction').to route_to('payments#process_transaction', format: :json)
    end
  end
end
