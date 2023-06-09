# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.action_mailer.smtp_settings = {
    address:               ENV.fetch('SMTP_HOST', nil),
    port:                  ENV['SMTP_PORT'].to_i,
    enable_start_tls_auto: true,
    user_name:             ENV.fetch('SMTP_USER', nil),
    password:              ENV.fetch('SMTP_PASS', nil),
    authentication:        ENV.fetch('SMTP_AUTH', 'plain'),
    domain:                ENV.fetch('SMTP_DOMAIN', nil),
    openssl_verify_mode:   OpenSSL::SSL::VERIFY_NONE
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  config.active_record.encryption.primary_key = 'fake'
  config.active_record.encryption.deterministic_key = 'fake'
  config.active_record.encryption.key_derivation_salt = 'fake'

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  config.active_storage.service = :local

  config.monero_daemon = ENV.fetch('MONERO_DAEMON', 'stagenet.community.rino.io')
  config.monero_daemon_port = ENV.fetch('MONERO_DAEMON_PORT', '38081')
end
