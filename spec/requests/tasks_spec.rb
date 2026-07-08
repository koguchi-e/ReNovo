require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  describe "ログイン済みの場合" do
    let(:user) { create(:user) }
    let(:situation) { create(:situation, user: user) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      create(:task, situation: situation, position: 1)
      create(:task, situation: situation, position: 2)
      create(:task, situation: situation, position: 3)
      create(:task, situation: situation, position: 4)
      create(:task, situation: situation, position: 5)
    end

    it "タスク画面にアクセスできる" do
      get situation_tasks_path(situation)
      expect(response).to have_http_status(:success)
    end

    it "タスクを追加する" do
      expect do
        post situation_tasks_path(situation), params: {
          task: { content: "追加したタスク" }
        }
      end.to change(Task, :count).by(1)

      task = situation.tasks.order(:position).last

      expect(response).to redirect_to situation_tasks_path(situation)
      expect(task.content).to eq "追加したタスク"
      expect(task.situation).to eq situation
      expect(task.position).to eq(6)
      expect(flash[:notice]).to eq('タスクを追加しました。')
    end
    it "タスクが空欄だと追加できない" do
      expect do
        post situation_tasks_path(situation), params: {
          task: { content: "" }
        }
      end.not_to change(Task, :count)
      expect(flash[:alert]).to eq('タスクの追加に失敗しました。')
    end
    it "タスクを更新できる" do
      task = create(:task, situation: situation, content: "古いタスク")
      patch situation_task_path(situation, task), params: {
        task: { content: "更新後のタスク" }
      }
      expect(task.reload.content).to eq "更新後のタスク"
      expect(task.reload.content).not_to eq "古いタスク"
      expect(response).to redirect_to situation_tasks_path(situation)
    end
    it "タスクを削除できる" do
      task = create(:task, situation: situation)
      expect {
        delete situation_task_path(situation, task)
      }.to change(Task, :count).by(-1)
      expect(response).to redirect_to situation_tasks_path(situation)
    end
  end
end
