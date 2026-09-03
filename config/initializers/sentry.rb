# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.enabled_environments = %w[production]

  # 状況・問題・目標など、ReNovoの利用者入力をSentryへ送らない。
  config.send_default_pii = false
  config.send_client_reports = false
  config.traces_sample_rate = 0.0

  config.before_send = lambda do |event, _hint|
    event.request = nil
    event.user = nil
    event
  end
end
