# frozen_string_literal: true

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

  describe "GET /auth/google_oauth2/callback" do
    context "未登録ユーザーの場合" do
      it "ユーザーを作成し、ログインする" do
        expect do
          get "/auth/google_oauth2/callback"
        end.to change(User, :count).by(1)

        expect(session[:user_id]).to be_present

        expect(response).to redirect_to new_situation_path
        expect(flash[:notice]).to eq("ログインしました。")
      end
    end

    context "登録済みユーザーの場合" do
      let!(:user) do
        FactoryBot.create(
          :user,
          provider: "google_oauth2",
          uid: "123456789",
          email_address: "test@example.com",
          name: "テスト太郎"
        )
      end

      it "新しいユーザーを作成しない" do
        expect do
          get "/auth/google_oauth2/callback"
        end.not_to change(User, :count)

        expect(session[:user_id]).to eq(user.id)
      end
    end
  end

  describe "DELETE /logout" do
    context "ログインしている場合" do
      before do
        get "/auth/google_oauth2/callback"
      end

      it "ログアウトしてトップページへリダイレクトする" do
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
end
