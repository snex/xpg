# frozen_string_literal: true

class SweepExpiredInvoicesJob
  include Sidekiq::Job

  def perform
    Invoice.expired.pluck(:id).each do |invoice_id|
      DeleteInvoiceJob.perform_async(invoice_id)
    end
  end
end
