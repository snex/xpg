# frozen_string_literal: true

class WalletMailer < ApplicationMailer
  def payment_without_invoice
    @wallet = params[:wallet]
    @transaction = params[:transaction]

    mail(to: MailConfig.to, subject: I18n.t('wallet.mailer.payment_without_invoice.subject'))
  end
end
