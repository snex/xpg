# frozen_string_literal: true

class InvoicePreview < ActionMailer::Preview
  def overpayment
    InvoiceMailer.with(invoice: FactoryBot.build(:invoice)).overpayment
  end

  def partial_payment
    InvoiceMailer.with(invoice: FactoryBot.build(:invoice)).partial_payment
  end
end
