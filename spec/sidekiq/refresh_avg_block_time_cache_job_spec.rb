# frozen_string_literal: true

RSpec.describe RefreshAvgBlockTimeCacheJob, type: :job do
  include_context 'when MoneroRpcService is needed'

  before do
    allow(rpc).to receive(:avg_block_time).and_return(1)
  end

  it 'calls avg_block_time' do
    described_class.new.perform

    expect(rpc).to have_received(:avg_block_time).once
  end
end
