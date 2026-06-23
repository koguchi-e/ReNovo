require "rails_helper"

RSpec.describe "Googleログイン", type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email: "test@example.com",
          name: "テスト太郎"
        }
      )
  end

  it "ユーザーを作成し、ログインする" do
    expect do
      get "/auth/google_oauth2/callback"
    end.to change(User, :count).by(1)

    expect(session[:user_id]).to be_present
  end

  context "既存ユーザーがいる場合" do
    let!(:user) do
      FactoryBot.create(
        :user,
        provider: "google_oauth2",
        uid: "123456789",
        email_address: "test@example.com",
        name: "テスト太郎"
      )
    end

    it "新しく追加しない" do
      expect do
        get "/auth/google_oauth2/callback"
      end.not_to change(User, :count)
    end
  end
end
