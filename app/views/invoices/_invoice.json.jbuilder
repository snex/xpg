# frozen_string_literal: true

json.extract! invoice, :id, :wallet_id, :amount, :expires_at, :external_id, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
