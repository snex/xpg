# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    name               { Faker::File.file_name }
    password           { Faker::Internet.password }
    rpc_creds          { Faker::Internet.password }
    pid                { nil }
    ready_to_run       { [true, false].sample }
    default_expiry_ttl { nil }
    sequence :port do |n|
      n + 10_000
    end

    trait :with_default_expiry_ttl do
      default_expiry_ttl { rand(1..9999) }
    end

    factory :named_wallet do
      sequence :name do |n|
        "Name #{n}"
      end
      password           { Faker::Internet.password }
      rpc_creds          { Faker::Internet.password }
      pid                { nil }
      ready_to_run       { [true, false].sample }
      default_expiry_ttl { nil }
      sequence :port do |n|
        n + 10_000
      end
    end
  end
end
