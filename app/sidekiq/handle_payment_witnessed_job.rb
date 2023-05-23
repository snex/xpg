# frozen_string_literal: true

class HandlePaymentWitnessedJob
  include Sidekiq::Job

  def perform(payment_id)
    CallbackService.handle_payment_witnessed(Payment.find(payment_id).invoice)
  end
end
