# frozen_string_literal: true

class RefreshAvgBlockTimeCacheJob
  include Sidekiq::Job

  def perform
    MoneroRpcService.new.avg_block_time
  end
end
