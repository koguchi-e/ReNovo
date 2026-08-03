require "rails_helper"

RSpec.describe "セッション管理", type: :request do
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

    expect(response).to redirect_to new_situation_path
    expect(flash[:notice]).to eq('ログインしました。')
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

  context "ログインしている場合" do
    before do
      get "/auth/google_oauth2/callback"
    end

    it "ログアウトする" do
      delete logout_path
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("ログアウトしました。")
    end

    it "ログアウトするとふりかえり画面には入れない" do
      delete logout_path
      get new_situation_path
      expect(response).to redirect_to(root_path)
    end
  end
end
