# frozen_string_literal: true

class DeleteInvoiceJob
  include Sidekiq::Job

  def perform(invoice_id)
    Invoice.find(invoice_id).gracefully_delete
  rescue ActiveRecord::RecordNotFound
    # invoice already deleted? great. do nothing
    nil
  end
end
