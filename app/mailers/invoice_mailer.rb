# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  before_action { @invoice = params[:invoice] }

  def overpayment
    mail(to: MailConfig.to, subject: I18n.t('invoice.mailer.overpayment.subject'))
  end

  def partial_payment
    mail(to: MailConfig.to, subject: I18n.t('invoice.mailer.partial_payment.subject'))
  end
end
