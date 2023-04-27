# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    name      { Faker::Lorem.unique }
    password  { Faker::Internet.password }
    rpc_creds { Faker::Internet.password }
    pid       { nil }
    sequence :port do |n|
      n + 10_000
    end
  end
end
