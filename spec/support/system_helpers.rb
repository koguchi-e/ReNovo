module SystemHelpers
  def sign_in_as(user)
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: {
          email: user.email_address,
          name: user.name
        }
      )
    visit root_path
    click_button "Googleでログイン"
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
