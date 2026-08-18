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
      it "ふりかえりを作成し、タスク生成ジョブを登録する" do
        expect do
          post situations_path, params: params
        end.to change(Situation, :count).by(1)

        situation = Situation.last

        expect(GenerateTasksJob).to have_received(:perform_later).with(situation_id: situation.id)

        expect(response).to redirect_to situation_tasks_path(situation)
        expect(flash[:notice]).to eq("質問に回答しました。")
      end
    end

    context "今月の上限に達している場合" do
      before do
        create_list(:situation, SituationsController::MONTHLY_USAGE_LIMIT, user: user, created_at: Time.current)
      end

      it "作成されず429で入力画面を再表示する" do
        expect do
          post situations_path, params: params
        end.not_to change(Situation, :count)

        expect(response).to have_http_status(:too_many_requests)
        expect(response.body).to include("今月の利用上限に達しました。翌月に再び利用できます。")
        expect(GenerateTasksJob).not_to have_received(:perform_later)
      end
    end

    context "入力内容が不正な場合" do
      before do
        params[:situation][:fact] = ""
      end

      it "作成せず入力画面を再表示する" do
        expect do
          post situations_path, params: params
        end.not_to change(Situation, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("質問の回答に失敗しました。")
        expect(GenerateTasksJob).not_to have_received(:perform_later)
      end
    end
  end

  describe "GET /situations/:id" do
    context "ログインしている場合" do
      let(:user) { create(:user) }
      let(:situation) { create(:situation, user: user) }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      it "ふりかえりの詳細とposition順にタスクを表示する" do
       create(:task, situation: situation, content: "1個目のタスク", position: 1)
       create(:task, situation: situation, content: "2個目のタスク", position: 2)

        get situation_path(situation)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(situation.fact)
        expect(response.body).to include("1個目のタスク")
        expect(response.body).to include("2個目のタスク")
      end
    end
  end
end
