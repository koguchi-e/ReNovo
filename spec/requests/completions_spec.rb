# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Situations::Completions", type: :request do
  let(:user) { create(:user) }
  let(:situation) { create(:situation, user:) }

  before do
    sign_in_as(user)
  end

  describe "GET /situations/:situation_id/completion" do
    context "タスクが存在する場合" do
      it "最初のタスクとposition順のタスク一覧が表示される" do
        create(:task, situation: situation, content: "1個目のタスク", position: 1)
        create(:task, situation: situation, content: "2個目のタスク", position: 2)

        get situation_completion_path(situation)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("最初に取り組むタスク")
        expect(response.body.index("1個目のタスク")).to be < response.body.index("2個目のタスク")
      end
    end

    context "タスクが存在しない場合" do
      it "タスク一覧にリダイレクトする" do
        get situation_completion_path(situation)

        expect(response).to redirect_to(situation_tasks_path(situation))
        expect(flash[:alert]).to eq("タスクがありません")
      end
    end

    it "他のユーザーの状況整理の完了画面は表示できない" do
      other_situation = create(:situation)
      create(:task, situation: other_situation)

      get situation_completion_path(other_situation)

      expect(response).to have_http_status(:not_found)
    end
  end
end
