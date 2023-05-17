# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: MailConfig.from
  layout 'mailer'
end
