# frozen_string_literal: true

class HandlePaymentWitnessedJob
  include Sidekiq::Job

  def perform(payment_id)
    payment = Payment.find(payment_id)
    CallbackService.handle_payment_witnessed(payment.invoice.callback_url, payment.amount.to_i, payment.confirmations,
                                             payment.necessary_confirmations)
  end
end
