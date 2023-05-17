# frozen_string_literal: true

module MailConfig
  def self.enabled?
    Rails.application.config.mail.values.all?(&:present?)
  end

  def self.disabled?
    !enabled?
  end

  def self.from
    return if disabled?

    Rails.application.config.mail.from
  end

  def self.to
    return if disabled?

    Rails.application.config.mail.to
  end
end
