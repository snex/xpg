# frozen_string_literal: true

RSpec.shared_context 'when MoneroRPC::IncomingTransfer is needed' do
  include_context 'when MoneroRpcService is needed'

  let(:tx) { instance_double(MoneroRPC::IncomingTransfer) }

  before { allow(rpc).to receive(:transfer_details).and_return(tx) }
end
