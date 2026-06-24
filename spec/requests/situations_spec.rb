require 'rails_helper'

RSpec.describe "Situations", type: :request do
  describe "未ログイン時はトップ画面にリダイレクトする" do
    it "質問入力画面にアクセスする" do
      get new_situation_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "ログイン時はアクセスできる" do
    let(:user) { create(:user) }
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it "質問入力画面にアクセスできる" do
      get new_situation_path
      expect(response).to have_http_status(:success)
    end

    let(:params) do
      {
        situation: {
          fact: "仕事が忙しい",
          problem: "学習時間が取れない、疲れて寝てしまう",
          goal: "資格試験合格、毎日30分勉強する"
        }
      }
    end

    it "質問の作成に成功する" do
      expect do
        post situations_path, params: params
      end.to change(Situation, :count).by(1)
      expect(response).to redirect_to situation_tasks_path(Situation.last)
      expect(flash[:notice]).to eq('質問に回答しました。')
    end
  end
end
