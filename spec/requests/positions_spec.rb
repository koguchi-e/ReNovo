# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Positions", type: :request do
  let(:user) { create(:user) }
  let(:situation) { create(:situation, user: user) }

  before do
    sign_in_as(user)
  end

  describe "GET /situations/:situation_id/position/edit" do
    context "タスクが存在する場合" do
      it "position順にタスクを表示する" do
        create(:task, situation: situation, content: "1個目のタスク", position: 1)
        create(:task, situation: situation, content: "2個目のタスク", position: 2)

        get edit_situation_position_path(situation)

        expect(response).to have_http_status(:success)
        expect(response.body.index("1個目のタスク")).to be < response.body.index("2個目のタスク")
      end
    end

    context "タスクが存在しない場合" do
      it "タスク一覧へリダイレクトする" do
        get edit_situation_position_path(situation)

        expect(response).to redirect_to(situation_tasks_path(situation))
        expect(flash[:alert]).to eq("タスクがありません")
      end
    end
  end

  describe "PATCH /situations/:situation_id/position" do
    it "指定した位置にタスクを移動する" do
      first_task = create(:task, situation: situation, content: "1個目のタスク", position: 1)
      second_task = create(:task, situation: situation, content: "2個目のタスク", position: 2)

      patch situation_position_path(situation), params: {
        task_id: second_task.id,
        insert_at: 1
      }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(second_task.reload.position).to eq(1)
      expect(first_task.reload.position).to eq(2)
    end

    it "他のSituationのタスクは更新できない" do
      other_situation = create(:situation, user:)
      other_task = create(:task, situation: other_situation)
      original_position = other_task.position

      patch situation_position_path(situation), params: {
        task_id: other_task.id,
        insert_at: 1
      }, as: :json
      expect(response).to have_http_status(:not_found)
      expect(other_task.reload.position).to eq(original_position)
    end
  end
end
