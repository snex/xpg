# frozen_string_literal: true

class InvoicePreview < ActionMailer::Preview
  def overpayment
    InvoiceMailer.with(invoice: Invoice.last).overpayment
  end

  def partial_payment
    InvoiceMailer.with(invoice: Invoice.last).partial_payment
  end
end
