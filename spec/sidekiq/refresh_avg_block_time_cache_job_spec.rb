# frozen_string_literal: true

RSpec.describe RefreshAvgBlockTimeCacheJob, type: :job do
  let(:rpc) { instance_double(MoneroRpcService) }

  before do
    allow(MoneroRpcService).to receive(:new).and_return(rpc)
    allow(rpc).to receive(:avg_block_time).and_return(1)
  end

  it 'calls MoneroRpcService.new.avg_block_time' do
    described_class.new.perform

    expect(rpc).to have_received(:avg_block_time).once
  end
end
