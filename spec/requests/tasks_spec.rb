# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tasks", type: :request do
  context "ログイン済みの場合" do
    let(:user) { create(:user) }
    let(:situation) { create(:situation, user: user) }

    before do
      sign_in_as(user)
    end

    describe "GET /situations/:situation_id/tasks" do
      it "タスク画面を表示する" do
        get situation_tasks_path(situation)
        expect(response).to have_http_status(:success)
      end

      it "他のユーザーの状況整理のタスクは表示できない" do
        other_situation = create(:situation)

        get situation_tasks_path(other_situation)

        expect(response).to have_http_status(:not_found)
      end

      context "タスクが存在する場合" do
        it "position順にタスクを表示する" do
          situation = create(:situation, user: user, status: :completed)
          create(:task, situation: situation, content: "1個目のタスク", position: 1)
          create(:task, situation: situation, content: "2個目のタスク", position: 2)

          get situation_tasks_path(situation)

          expect(response).to have_http_status(:success)
          expect(response.body.index("1個目のタスク")).to be < response.body.index("2個目のタスク")
        end
      end

      context "Situationがタイムアウトしている場合" do
        it "failedに変更する" do
          situation = create(
            :situation,
            user: user,
            status: :pending,
            created_at: 6.minutes.ago
          )
          get situation_tasks_path(situation)
          expect(situation.reload).to be_failed
        end
      end

      context "Situationがタイムアウトしてない場合" do
        it "pendingのままにする" do
          situation = create(
            :situation,
            user: user,
            status: :pending,
            created_at: 4.minutes.ago
          )
          get situation_tasks_path(situation)
          expect(situation.reload).to be_pending
        end
      end

      context "Situationがcompletedの場合" do
        it "completedのままにする" do
          situation = create(
            :situation,
            user: user,
            status: :completed,
            created_at: 6.minutes.ago
          )
          get situation_tasks_path(situation)
          expect(situation.reload).to be_completed
        end
      end

      context "after_createがtasks_indexの場合" do
        it "タスクを作成し、タスクが一覧画面にリダイレクトする" do
          expect do
            post situation_tasks_path(situation), params: {
              task: { content: "机を整理する" },
              after_create: "tasks_index"
            },
            as: :turbo_stream
          end.to change(Task, :count).by(1)
          expect(response).to redirect_to(situation_tasks_path(situation))
          expect(response).to have_http_status(:see_other)
          expect(flash[:notice]).to include("タスクを追加しました。")
        end
        it "タスクを作成できない場合、状況詳細画面へリダイレクトする" do
          expect do
            post situation_tasks_path(situation),
              params: {
                task: { content: "" },
                after_create: "tasks_index"
              },
              as: :turbo_stream
          end.not_to change(Task, :count)

          expect(response).to redirect_to(situation_path(situation))
          expect(response).to have_http_status(:see_other)
          expect(flash[:alert]).to be_present
        end
      end
    end

    describe "PATCH /situations/:situation_id/tasks/:id" do
      it "指定した位置にタスクを移動する" do
        first_task = create(:task, situation: situation, content: "1個目のタスク", position: 1)
        second_task = create(:task, situation: situation, content: "2個目のタスク", position: 2)

        patch situation_task_path(situation, second_task), params: {
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

        patch situation_task_path(situation, second_task), params: {
          insert_at: 1
        }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(first_task.reload.position).to eq(1)
        expect(second_task.reload.position).to eq(2)
      end

      it "他のSituationのタスクは更新できない" do
        other_situation = create(:situation, user: user)
        other_task = create(:task, situation: other_situation)
        original_position = other_task.position

        patch situation_task_path(situation, other_task), params: {
          insert_at: 1
        }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(other_task.reload.position).to eq(original_position)
      end

      it "他のユーザーの状況整理のタスク順は更新できない" do
        other_situation = create(:situation)
        first_task = create(:task, situation: other_situation, position: 1)
        second_task = create(:task, situation: other_situation, position: 2)

        patch situation_task_path(other_situation, second_task), params: {
          insert_at: 1
        }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(first_task.reload.position).to eq(1)
        expect(second_task.reload.position).to eq(2)
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
            }, as: :turbo_stream
          end.to change(Task, :count).by(1)

          task = situation.tasks.order(:position).last

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/vnd.turbo-stream.html")
          expect(response.body).to include('target="status_screen"')
          expect(response.body).to include('target="flash_messages"')
          expect(response.body).to include("追加したタスク")
          expect(task.content).to eq "追加したタスク"
          expect(task.situation).to eq situation
          expect(task.position).to eq(6)
          expect(response.body).to include("タスクを追加しました。")
        end
      end

      context "タスクの内容が空欄の場合" do
        it "タスクを追加しない" do
          expect do
            post situation_tasks_path(situation), params: {
              task: { content: "" }
            }
          end.not_to change(Task, :count)
          expect(flash[:alert]).to eq("タスクの追加に失敗しました。")
        end
      end

      it "他のユーザーの状況整理にはタスクを追加できない" do
        other_situation = create(:situation)

        expect do
          post situation_tasks_path(other_situation), params: {
            task: { content: "追加しようとしたタスク" }
          }
        end.not_to change(Task, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "PATCH /situations/:situation_id/tasks/:id" do
      it "タスクを更新する" do
        task = create(:task, situation: situation, content: "古いタスク")
        patch situation_task_path(situation, task), params: {
          task: { content: "更新後のタスク" }
        }, as: :turbo_stream
        expect(task.reload.content).to eq "更新後のタスク"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('target="status_screen"')
        expect(response.body).to include('target="flash_messages"')
        expect(response.body).to include("更新後のタスク")
        expect(response.body).not_to include("古いタスク")
        expect(response.body).to include("タスクを更新しました。")
      end

      it "タスクの内容が空欄の場合、タスクの更新に失敗する" do
        task = create(:task, situation: situation, content: "古いタスク")
        patch situation_task_path(situation, task), params: {
          task: { content: "" }
        }
        expect(response).to redirect_to situation_tasks_path(situation)
        expect(task.reload.content).to eq "古いタスク"
        expect(flash[:alert]).to eq("タスクの更新に失敗しました。")
      end

      it "他のユーザーのタスクは更新できない" do
        other_task = create(:task, content: "変更前のタスク")

        patch situation_task_path(other_task.situation, other_task), params: {
          task: { content: "変更後のタスク" }
        }

        expect(response).to have_http_status(:not_found)
        expect(other_task.reload.content).to eq("変更前のタスク")
      end
    end

    describe "DELETE /situations/:situation_id/tasks/:id" do
      it "タスクを削除する" do
        remaining_task = create(:task, situation: situation, content: "残るタスク")
        task = create(:task, situation: situation, content: "削除対象のタスク")
        expect {
          delete situation_task_path(situation, task), as: :turbo_stream
        }.to change(Task, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('target="status_screen"')
        expect(response.body).to include('target="flash_messages"')
        expect(response.body).to include(remaining_task.content)
        expect(response.body).not_to include(task.content)
        expect(response.body).to include("タスクを削除しました。")
      end

      it "タスクの削除に失敗する" do
        task = create(:task, situation: situation)
        allow_any_instance_of(Task).to receive(:destroy).and_return(false)

        expect {
          delete situation_task_path(situation, task)
        }.not_to change(Task, :count)

        expect(response).to redirect_to situation_tasks_path(situation)
        expect(flash[:alert]).to eq("タスクの削除に失敗しました。")
      end

      it "他のユーザーのタスクは削除できない" do
        other_task = create(:task)

        expect do
          delete situation_task_path(other_task.situation, other_task)
        end.not_to change(Task, :count)

        expect(response).to have_http_status(:not_found)
      end

      it "タスクを全て削除すると空状態を表示する" do
        task = create(:task, situation: situation)

        delete situation_task_path(situation, task),
              as: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('target="status_screen"')
        expect(response.body).to include('target="flash_messages"')
        expect(response.body).to include("タスクはまだありません")
      end
    end

    describe "タスク生成失敗後のPOST /situations/:situation_id/tasks" do
      context "タスクの生成に失敗している場合" do
        let(:situation) { create(:situation, user: user, status: :failed) }

        it "タスクを手動で追加すると、生成完了状態になる" do
          expect do
            post situation_tasks_path(situation), params: {
              task: { content: "手動で追加したタスク" }
            }, as: :turbo_stream
          end.to change(Task, :count).by(1)

          task = situation.tasks.order(:position).last

          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq("text/vnd.turbo-stream.html")
          expect(response.body).to include('target="status_screen"')
          expect(response.body).to include('target="flash_messages"')
          expect(response.body).to include("手動で追加したタスク")
          expect(response.body).to include("タスクを追加しました。")
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
          expect(flash[:alert]).to eq("タスクの追加に失敗しました。")
        end
      end
    end
  end
end
