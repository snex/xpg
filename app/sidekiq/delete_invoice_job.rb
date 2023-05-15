# frozen_string_literal: true

class DeleteInvoiceJob
  include Sidekiq::Job

  def perform(invoice_id)
    Invoice.find(invoice_id).gracefully_delete
  end
end
