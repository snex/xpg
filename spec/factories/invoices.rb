# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    wallet
    amount           { rand(1e15) }
    expires_at       { 1.hour.from_now }
    external_id      { SecureRandom.uuid }
    incoming_address { SecureRandom.uuid }
    payment_id       { SecureRandom.uuid }
    callback_url     { Faker::Internet.url }
    qr_code          { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/hello.svg')) }

    trait :with_payments do
      payments { build_list(:payment, 3) }
    end
  end
end
