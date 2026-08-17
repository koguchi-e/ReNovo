# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Situations", type: :request do
  describe "GET /situations/new" do
    context "ログインしていない場合" do
      it "トップ画面にリダイレクトする" do
        get new_situation_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      it "質問入力画面を表示する" do
        get new_situation_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /situations" do
    let(:user) { create(:user) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow(GenerateTasksJob).to receive(:perform_later)
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

    context "ログインしている場合" do
      it "状況整理を作成し、タスク生成ジョブを登録する" do
        expect do
          post situations_path, params: params
        end.to change(Situation, :count).by(1)

        situation = Situation.last

        expect(GenerateTasksJob).to have_received(:perform_later).with(situation_id: situation.id)

        expect(response).to redirect_to situation_tasks_path(situation)
        expect(flash[:notice]).to eq("質問に回答しました。")
      end

      it "新規作成後の詳細画面に完了メッセージを一度だけ表示する" do
        post situations_path, params: params
        situation = Situation.last
        create(:task, situation: situation)

        get situation_path(situation, completed: true)
        expect(response.body).to include("タスクの整理が完了しました！")

        get situation_path(situation, completed: true)
        expect(response.body).not_to include("タスクの整理が完了しました！")
      end

      it "生成完了後のタスク編集画面に案内を一度だけ表示する" do
        post situations_path, params: params
        situation = Situation.last
        create(:task, situation: situation)
        situation.completed!

        get situation_tasks_path(situation)
        expect(response.body).to include("タスクを生成しました。")
        expect(response.body).to include("タスクの追加・編集・削除ができます。")
        expect(response.body).to include("タスクの順番も自由に並べ替えられます。")

        get situation_tasks_path(situation)
        expect(response.body).not_to include("タスクを生成しました。")
      end
    end
  end
end
