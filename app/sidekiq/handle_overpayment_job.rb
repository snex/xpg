# frozen_string_literal: true

class HandleOverpaymentJob
  include Sidekiq::Job

  def perform(invoice_id)
    Invoice.find(invoice_id).handle_overpayment
  end
end
