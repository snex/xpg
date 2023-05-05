# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoneroRpcService do
  let(:wallet) { build(:wallet) }
  let(:rpc_service) { described_class.new(wallet) }

  before { allow(MoneroRPC).to receive(:new).and_return(rpc) }

  describe '#create_rpc_wallet' do
    let(:rpc) { instance_double(MoneroRPC::Client) }

    before do
      allow(rpc).to receive(:generate_view_wallet)
      allow(rpc).to receive(:stop_wallet)
      rpc_service.create_rpc_wallet('a', '1', 2)
    end

    it 'calls create_wallet' do
      expect(rpc).to have_received(:generate_view_wallet).with(wallet.name, 'a', wallet.password, '1', 2).once
    end

    it 'calls stop_wallet' do
      expect(rpc).to have_received(:stop_wallet).once
    end
  end
end
