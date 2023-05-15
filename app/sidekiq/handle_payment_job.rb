# frozen_string_literal: true

class HandlePaymentJob
  include Sidekiq::Job

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    invoice.callback
  end
end
