# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.enabled_environments = %w[production]
  config.send_default_pii = false
  config.send_client_reports = false
  config.traces_sample_rate = 0.0
end
