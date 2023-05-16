# frozen_string_literal: true

json.extract! invoice, :id, :wallet_id, :expires_at, :external_id, :incoming_address, :payment_id,
              :callback_url, :created_at, :updated_at
json.amount XMR.new(invoice.amount.to_i).to_s
json.estimated_confirm_time invoice.estimated_confirm_time
json.qr_code rails_blob_url(invoice.qr_code)
