# frozen_string_literal: true

RSpec.shared_context 'when MoneroRpcService is needed' do
  let(:rpc) { instance_double(MoneroRpcService) }

  before do
    allow(MoneroRpcService).to receive(:new).and_return(rpc)
  end
end
