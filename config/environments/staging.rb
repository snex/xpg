# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info
  Sidekiq.configure_server do |config|
    config.logger.level = 'INFO'
  end

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in staging.
  config.cache_store = :redis_cache_store

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.active_record.encryption.primary_key = ENV.fetch('ENCRYPTION_PRIMARY_KEY')
  config.active_record.encryption.deterministic_key = ENV.fetch('ENCRYPTION_DETERMINISTIC_KEY')
  config.active_record.encryption.key_derivation_salt = ENV.fetch('ENCRYPTION_KEY_DERIVATION_SALT')

  config.action_mailer.smtp_settings = {
    address:               ENV.fetch('SMTP_HOST', nil),
    port:                  ENV['SMTP_PORT'].to_i,
    enable_start_tls_auto: true,
    user_name:             ENV.fetch('SMTP_USER', nil),
    password:              ENV.fetch('SMTP_PASS', nil),
    authentication:        ENV.fetch('SMTP_AUTH', 'plain'),
    domain:                ENV.fetch('SMTP_DOMAIN', nil)
  }

  Rails.application.routes.default_url_options[:host] = ENV.fetch('XPG_HOST')
  config.active_storage.service = :local

  config.monero_daemon = ENV.fetch('MONERO_DAEMON')
  config.monero_daemon_port = ENV.fetch('MONERO_DAEMON_PORT', '18081')
end
