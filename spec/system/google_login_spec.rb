require "rails_helper"

RSpec.describe "Googleログイン", type: :request do
  it "ユーザーを作成し、ログインする" do
    expect do
      get "/auth/google_oauth2/callback"
    end.to change(User, :count).by(1)

    expect(session[:user_id]).to be_present
  end

  let!(:user) do
    User.create!(
      email: "test@example.com",
      provider: "google_oauth2",
      uid: "123456789"
    )
  end

  it "既存ユーザーがいる場合は新しく追加しない " do
    expect do
      get "/auth/google_oauth2/callback"
    end.not_to change(User, :count)
  end
end
