module RequestHelpers
  def sign_in_as(user)
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: {
          email_address: user.email_address,
          name: user.name
        }
      )
    get "/auth/google_oauth2/callback"
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
