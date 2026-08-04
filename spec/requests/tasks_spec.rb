require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  context "ログイン済みの場合" do
    let(:user) { create(:user) }
    let(:situation) { create(:situation, user: user) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    describe "GET /situations/:situation_id/tasks" do
      it "タスク画面を表示する" do
        get situation_tasks_path(situation)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /situations/:situation_id/tasks" do
      context "タスクが既に5件作成されている場合" do
        before do
          1.upto(5) do |position|
            create(:task, situation: situation, position: position)
          end
        end

        it "positionが6のタスクを追加する" do
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
      end

      context "タスクの内容が空欄の場合" do
        it "タスクを追加しない" do
          expect do
            post situation_tasks_path(situation), params: {
              task: { content: "" }
            }
          end.not_to change(Task, :count)
          expect(flash[:alert]).to eq('タスクの追加に失敗しました。')
        end
      end
    end

    describe "PATCH /situations/:situation_id/tasks/:id" do
      it "タスクを更新する" do
        task = create(:task, situation: situation, content: "古いタスク")
        patch situation_task_path(situation, task), params: {
          task: { content: "更新後のタスク" }
        }
        expect(task.reload.content).to eq "更新後のタスク"
        expect(task.reload.content).not_to eq "古いタスク"
        expect(response).to redirect_to situation_tasks_path(situation)
      end
    end

    describe "DELETE /situations/:situation_id/tasks/:id" do
      it "タスクを削除する" do
        task = create(:task, situation: situation)
        expect {
          delete situation_task_path(situation, task)
        }.to change(Task, :count).by(-1)
        expect(response).to redirect_to situation_tasks_path(situation)
      end
    end

    describe "POST /situations/:situation_id/tasks after generation failure" do
      context "タスクの生成に失敗している場合" do
        let(:situation) { create(:situation, user: user, status: :failed) }

        it "タスクを手動で追加すると、生成完了状態になる" do
          expect do
            post situation_tasks_path(situation), params: {
              task: { content: "手動で追加したタスク" }
            }
          end.to change(Task, :count).by(1)

          task = situation.tasks.order(:position).last

          expect(response).to redirect_to situation_tasks_path(situation)
          expect(task.content).to eq "手動で追加したタスク"
          expect(task.position).to eq(1)
          expect(situation.reload).to be_completed
        end

        it "手動追加に失敗した場合は、failedのままになる" do
          expect do
            post situation_tasks_path(situation), params: {
              task: { content: "" }
            }
          end.not_to change(Task, :count)

          expect(situation.reload).to be_failed
          expect(flash[:alert]).to eq('タスクの追加に失敗しました。')
        end
      end
    end
  end
end
