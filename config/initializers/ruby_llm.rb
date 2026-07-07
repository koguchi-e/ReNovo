RubyLLM.configure do |config|
  config.openai_api_key =
    if Rails.env.test?
      "dummy-api-key-for-test"
    else
      Rails.application.credentials.dig(:openai, :api_key)
    end
  config.default_model = "gpt-4o-mini"
end
