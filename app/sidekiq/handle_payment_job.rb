# frozen_string_literal: true

class HandlePaymentJob
  include Sidekiq::Job

  def perform(invoice_id)
    Invoice.find(invoice_id).handle_payment_complete
  end
end
