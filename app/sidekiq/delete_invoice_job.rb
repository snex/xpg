# frozen_string_literal: true

class DeleteInvoiceJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
  end
end
