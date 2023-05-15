# frozen_string_literal: true

class HandleOverpaymentJob
  include Sidekiq::Job

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)

    # TODO: send email about overpayment

    HandlePaymentJob.perform_async(invoice.id)
  end
end
