# frozen_string_literal: true

json.extract! invoice, :id, :wallet_id, :expires_at, :external_id, :incoming_address, :payment_id,
              :callback_url, :created_at, :updated_at
json.amount invoice.amount.to_i
json.url invoice_url(invoice, format: :json)
