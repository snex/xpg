# frozen_string_literal: true

class SweepExpiredInvoicesJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
  end
end
