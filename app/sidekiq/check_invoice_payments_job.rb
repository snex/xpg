# frozen_string_literal: true

class CheckInvoicePaymentsJob
  include Sidekiq::Job

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)

    return if invoice.unpaid?

    if invoice.overpaid?
      # enqueue a job to send an email about an overpayment
      Rails.logger.error('overpaid')
    end

    Rails.logger.error('paid')

    # ping callback URL
    #
    # enqueue a job to delete the invoice and all payments
  end
end
