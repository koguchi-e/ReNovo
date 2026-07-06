RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.openai[:api_key]
  config.default_model = "gpt-4o-mini"
end
