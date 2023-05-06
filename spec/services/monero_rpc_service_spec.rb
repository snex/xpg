# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoneroRpcService do
  let(:wallet) { build(:wallet) }
  let(:rpc_service) { described_class.new(wallet) }
  let(:rpc) { instance_double(MoneroRPC::Client) }
  let(:drpc) { instance_double(MoneroRPC::Client) }

  before { allow(MoneroRPC).to receive(:new).and_return(rpc, drpc) }

  describe '#current_height' do
    subject(:current_height) { rpc_service.current_height }

    before { allow(drpc).to receive(:get_info).and_return({ 'height' => 69_420 }) }

    it 'calls get_info' do
      current_height

      expect(drpc).to have_received(:get_info).once
    end

    it { is_expected.to eq(69_420) }
  end

  describe '#create_rpc_wallet' do
    before do
      allow(drpc).to receive(:get_info).and_return({ 'height' => 0 })
      allow(rpc).to receive(:generate_view_wallet)
      allow(rpc).to receive(:stop_wallet)
      rpc_service.create_rpc_wallet('a', '1')
    end

    it 'calls create_wallet' do
      expect(rpc).to have_received(:generate_view_wallet).with(wallet.name, 'a', wallet.password, '1', 0).once
    end

    it 'uses the current height from the daemon' do
      expect(drpc).to have_received(:get_info).once
    end

    it 'calls stop_wallet' do
      expect(rpc).to have_received(:stop_wallet).once
    end
  end
end
