# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    name     { Faker::Lorem.unique }
    password { Faker::Internet.password }
    sequence :port do |n|
      n + 10_000
    end
    pid { nil }
  end
end
