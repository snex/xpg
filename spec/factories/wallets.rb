# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    name         { Faker::File.file_name }
    password     { Faker::Internet.password }
    rpc_creds    { Faker::Internet.password }
    pid          { nil }
    ready_to_run { [true, false].sample }
    sequence :port do |n|
      n + 10_000
    end
  end
end
