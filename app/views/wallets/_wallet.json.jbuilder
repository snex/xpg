# frozen_string_literal: true

json.extract! wallet, :id, :name, :port, :default_expiry_ttl, :pid, :status, :created_at, :updated_at
json.url wallet_url(wallet, format: :json)
