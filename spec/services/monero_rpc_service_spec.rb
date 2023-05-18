# frozen_string_literal: true

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

  describe '#avg_block_time' do
    subject { rpc_service.avg_block_time(3) }

    let(:block_headers) do
      { 'headers' => [
        { 'timestamp' =>  1 },
        { 'timestamp' =>  5 },
        { 'timestamp' => 11 }
      ] }
    end

    before do
      allow(rpc_service).to receive(:current_height).and_return(100)
      allow(drpc).to receive(:get_block_headers_range).and_return(block_headers)
    end

    it { is_expected.to eq(5) }
  end

  describe '#estimated_confirm_time' do
    subject { rpc_service.estimated_confirm_time(100) }

    before do
      allow(drpc).to receive(:get_last_block_header).and_return({ 'block_header' => { 'reward' => reward } })
      allow(rpc_service).to receive(:avg_block_time).and_return(120)
    end

    context 'when amount / reward is below 1' do
      let(:reward) { 1_000 }

      it { is_expected.to eq(2.minutes) }
    end

    context 'when amount / reward is above 10' do
      let(:reward) { 1 }

      it { is_expected.to eq(20.minutes) }
    end

    context 'when amount / reward is between 1 and 10' do
      let(:reward) { rand(10..100) }

      it { is_expected.to eq((2 * (100 / reward)).minutes) }
    end
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

  describe '#save_wallet' do
    subject(:save_wallet) { rpc_service.save_wallet }

    before { allow(rpc).to receive(:save_wallet) }

    it 'calls save_wallet' do
      save_wallet

      expect(rpc).to have_received(:save_wallet).once
    end
  end

  describe '#generate_incoming_address' do
    subject(:generate_incoming_address) { rpc_service.generate_incoming_address }

    before { allow(rpc).to receive(:make_integrated_address) }

    it 'calls make_integrated_address' do
      generate_incoming_address

      expect(rpc).to have_received(:make_integrated_address).once
    end
  end

  describe '#generate_uri' do
    subject(:generate_uri) { rpc_service.generate_uri('1234', 1) }

    before { allow(rpc).to receive(:make_uri).and_return({ 'uri' => 'hello' }) }

    it 'calls make_uri' do
      generate_uri

      expect(rpc).to have_received(:make_uri).with('1234', 1).once
    end

    it { is_expected.to eq('hello') }
  end

  describe '#transfer_details' do
    before { allow(rpc).to receive(:get_transfer_by_txid) }

    it 'calls get_transfer_by_txid with the supplied arg' do
      rpc_service.transfer_details('1234')

      expect(rpc).to have_received(:get_transfer_by_txid).with('1234').once
    end
  end
end
