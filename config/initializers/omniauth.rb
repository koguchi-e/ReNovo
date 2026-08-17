# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.test?
    provider(
      :google_oauth2,
      "dummy_client_id",
      "dummy_client_secret",
    )
  elsif Rails.application.credentials.google.present?
    provider(
      :google_oauth2,
      Rails.application.credentials.google[:client_id],
      Rails.application.credentials.google[:client_secret],
      scope: "email,profile",
      prompt: "select_account",
      image_aspect_ratio: "square",
      image_size: 50,
    )
  end
end
