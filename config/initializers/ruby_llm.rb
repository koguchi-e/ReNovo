RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.openai[:api_key]
  config.default_model = "gpt-4o-mini"
  config.use_new_acts_as = true
end
