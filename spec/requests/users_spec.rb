require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let!(:situation) { create(:situation, user: user) }
  let!(:task) { create(:task, situation: situation) }

  before do
    sign_in_as(user)
  end

  describe "DELETE /user" do
    it "ユーザーと関連するふりかえり・タスクが削除される" do
      expect { delete user_path }.to change(User, :count).by(-1).and change(Situation, :count).by(-1).and change(Task, :count).by(-1)
    end

    it "退会するとトップページにリダイレクトする" do
      delete user_path
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("退会が完了しました。")
    end

    it "退会後再登録でき、ふりかえり・タスク・使用制限もリセットされる" do
      delete user_path
      expect do
        get "/auth/google_oauth2/callback"
      end.to change(User, :count).by(1)

      recreated_user = User.find(session[:user_id])

      expect(response).to redirect_to new_situation_path
      expect(flash[:notice]).to eq('ログインしました。')

      expect(Situation.count).to eq(0)
      expect(Task.count).to eq(0)
      expect(recreated_user.situations.where(created_at: Time.current.all_month).count).to eq(0)
    end
  end
end
