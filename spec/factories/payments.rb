# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    invoice
    amount       { rand(1e15) }
    monero_tx_id { SecureRandom.uuid }
  end
end
