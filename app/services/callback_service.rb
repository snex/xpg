# frozen_string_literal: true

require 'net/http'

class CallbackService
  def initialize(url, body)
    @uri = URI.parse(url)
    @headers = { 'Content-Type': 'application/json' }
    @body = body.to_json
  end

  def call
    Net::HTTP.post(@uri, @body, @headers)
  end

  def self.handle_payment_witnessed(invoice)
    body = {
      status:   'payment_witnessed',
      payments: invoice.payments_witnessed
    }
    new(invoice.callback_url, body).call
  end

  def self.handle_payment_complete(url)
    new(url, { status: 'payment_complete' }).call
  end
end
