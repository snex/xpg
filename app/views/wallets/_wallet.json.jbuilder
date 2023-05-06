# frozen_string_literal: true

json.extract! wallet, :id, :name, :port, :pid, :status, :created_at, :updated_at
json.url wallet_url(wallet, format: :json)
