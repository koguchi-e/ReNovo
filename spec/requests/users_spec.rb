require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let(:situation) { create(:situation, user: user) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    create(:task, situation: situation)
  end

  describe "退会処理" do
    it "ユーザーが削除される" do
      expect { delete user_path }.to change(User, :count).by(-1).and change(Situation, :count).by(-1).and change(Task, :count).by(-1)
    end

    it "退会するとトップページにリダイレクトする" do
      delete user_path
      expect(response).to redirect_to(root_path)
    end

    it "退会後、再登録できる" do
      delete user_path
      expect do
        get "/auth/google_oauth2/callback"
      end.to change(User, :count).by(1)

      expect(session[:user_id]).to be_present

      expect(response).to redirect_to new_situation_path
      expect(flash[:notice]).to eq('ログインしました。')

      expect(Situation.count).to eq(0)
      expect(Task.count).to eq(0)
    end
  end
end
