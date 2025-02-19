# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.8', '>= 7.0.8.1'

# nokogiri is now different per architecture so we need to require it here based on
# different architecture, even though we don't even explicitly use nokogiri as it
# is a requirement for rails.
case RUBY_PLATFORM
when 'aarch64-linux-gnu'
  gem 'nokogiri', '1.18.3-aarch64-linux-gnu'
when 'x86_64-linux'
  gem 'nokogiri', '1.18.3-x86_64-linux-gnu'
end

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.6'

gem 'redis', '~> 5.1'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Use Sass to process CSS
gem 'sassc-rails'

# sidekiq
gem 'sidekiq', '<8'
gem 'sidekiq-scheduler'

# Styling
gem 'bootstrap'
gem 'font-awesome-rails'

# Custom validators
gem 'validate_url'

# QR code generation
gem 'rqrcode'

# monero gem
gem 'monero', git: 'https://github.com/snex/monero.git', branch: 'update_monero'

group :development, :test do
  gem 'brakeman'
  gem 'bundler-audit', require: false
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop',             require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails',       require: false
  gem 'rubocop-rspec',       require: false
  gem 'shoulda-matchers'
  gem 'simplecov'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'json-schema'
  gem 'rspec-sidekiq'
end
