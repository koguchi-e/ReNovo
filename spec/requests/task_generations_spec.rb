# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "TaskGenerations", type: :request do
  describe "POST /situations/:situation_id/task_generation" do
    context "ログイン済みの場合" do
      let(:user) { create(:user) }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
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
    end
  end
end
