# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    sequence :name do |n|
      "Wallet-#{n}"
    end
    password           { Faker::Internet.password }
    rpc_creds          { Faker::Internet.password }
    pid                { nil }
    ready_to_run       { Faker::Boolean.boolean }
    default_expiry_ttl { nil }
    sequence :port do |n|
      n + 10_000
    end

    trait :with_default_expiry_ttl do
      default_expiry_ttl { rand(1..9999) }
    end
  end
end
