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

    it "他のユーザーの状況整理の並び替え画面は表示できない" do
      other_situation = create(:situation)
      create(:task, situation: other_situation)

      get edit_situation_position_path(other_situation)

      expect(response).to have_http_status(:not_found)
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

    it "タスクの移動に失敗した場合は並び順を変更しない" do
      first_task = create(:task, situation: situation, position: 1)
      second_task = create(:task, situation: situation, position: 2)
      allow_any_instance_of(Task).to receive(:insert_at).and_return(false)

      patch situation_position_path(situation), params: {
        task_id: second_task.id,
        insert_at: 1
      }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(first_task.reload.position).to eq(1)
      expect(second_task.reload.position).to eq(2)
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

    it "他のユーザーの状況整理のタスク順は更新できない" do
      other_situation = create(:situation)
      first_task = create(:task, situation: other_situation, position: 1)
      second_task = create(:task, situation: other_situation, position: 2)

      patch situation_position_path(other_situation), params: {
        task_id: second_task.id,
        insert_at: 1
      }, as: :json

      expect(response).to have_http_status(:not_found)
      expect(first_task.reload.position).to eq(1)
      expect(second_task.reload.position).to eq(2)
    end
  end
end
