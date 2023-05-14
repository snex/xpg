# frozen_string_literal: true

class CheckPaymentConfirmationsJob
  include Sidekiq::Job

  def perform(payment_id)
    payment = Payment.find(payment_id)

    if payment.confirmed?
      CheckInvoicePaymentsJob.perform_async(payment.invoice.id)
    else
      CheckPaymentConfirmationsJob.perform_in(30.seconds, payment_id)
    end
  end
end
