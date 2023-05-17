# frozen_string_literal: true

class CheckInvoicePaymentsJob
  include Sidekiq::Job

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)

    return if invoice.unpaid?

    if invoice.overpaid?
      HandleOverpaymentJob.perform_async(invoice.id)
    else
      HandlePaymentCompleteJob.perform_async(invoice.id)
    end
  end
end
