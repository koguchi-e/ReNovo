# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Situations::Completions", type: :request do
  let(:user) { create(:user) }
  let!(:situation) { create(:situation, user:) }

  before do
    sign_in_as(user)
  end

  describe "GET /situations/:situation_id/completion" do
    context "タスクが存在する場合" do
      it "タスク整理の完了を通知し、状況整理の詳細画面へリダイレクトする" do
        create(:task, situation:, position: 1)

        get situation_completion_path(situation)

        expect(response).to redirect_to(situation_path(situation))
        expect(flash[:notice]).to eq("タスクの整理が完了しました！")
      end
    end

    context "タスクが存在しない場合" do
      it "タスク編集画面へリダイレクトする" do
        get situation_completion_path(situation)

        expect(response).to redirect_to(situation_tasks_path(situation))
        expect(flash[:alert]).to eq("タスクがありません")
      end
    end

    context "他のユーザーの状況整理の場合" do
      it "アクセスできない" do
        other_situation = create(:situation)
        create(:task, situation: other_situation)

        get situation_completion_path(other_situation)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
