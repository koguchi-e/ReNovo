# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Situations::Completions", type: :request do
  let(:user) { create(:user) }
  let(:situation) { create(:situation, user:) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
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
  end
end
