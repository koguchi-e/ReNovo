# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TaskGenerations", type: :request do
  describe "POST /situations/:situation_id/task_generation" do
    context "ログイン済みの場合" do
      let(:user) { create(:user) }

      before do
        sign_in_as(user)
        allow(GenerateTasksJob).to receive(:perform_later)
      end

      context "Situationがfailedの場合" do
        let(:situation) { create(:situation, user: user, status: :failed) }

        it "failedのふりかえりのタスクを再生成できる" do
          post situation_task_generation_path(situation)

          expect(situation.reload).to be_generating
          expect(GenerateTasksJob).to have_received(:perform_later).with(situation_id: situation.id)
        end

        it "タスク生成画面にリダイレクトする" do
          post situation_task_generation_path(situation)
          expect(response).to redirect_to(situation_tasks_path(situation))
        end
      end

      context "Situationがfailed以外の場合" do
        let(:situation) { create(:situation, user: user, status: :generating) }

        it "再生成せず、警告付きでタスク画面にリダイレクトする" do
          post situation_task_generation_path(situation)

          expect(situation.reload).to be_generating
          expect(GenerateTasksJob).not_to have_received(:perform_later)
          expect(response).to redirect_to(situation_tasks_path(situation))
          expect(flash[:alert]).to eq("現在タスクの再生成はできません。")
        end
      end
    end
  end
end
