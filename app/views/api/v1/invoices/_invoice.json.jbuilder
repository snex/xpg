# frozen_string_literal: true

json.extract! invoice, :id, :expires_at, :incoming_address, :payment_id
json.amount XMR.new(invoice.amount.to_i).to_s
json.estimated_confirm_time invoice.estimated_confirm_time
json.qr_code rails_blob_url(invoice.qr_code)
json.payments invoice.payments_witnessed
