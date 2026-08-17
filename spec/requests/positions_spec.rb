require "rails_helper"

RSpec.describe "Positions", type: :request do
  describe "PATCH /situations/:situation_id/position" do
    let(:user) { create(:user) }
    let(:situation) { create(:situation, user:) }
    let!(:first_task) { create(:task, situation:, position: 1) }
    let!(:second_task) { create(:task, situation:, position: 2) }
    let!(:third_task) { create(:task, situation:, position: 3) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it "タスク編集画面から指定した順番へ移動できる" do
      patch situation_position_path(situation), params: {
        task_id: first_task.id,
        insert_at: 3
      }

      expect(response).to have_http_status(:no_content)
      expect(situation.tasks.order(:position)).to eq([second_task, third_task, first_task])
    end

    it "不正な順番では並べ替えを行わない" do
      expect_any_instance_of(Task).not_to receive(:insert_at)

      patch situation_position_path(situation), params: {
        task_id: first_task.id,
        insert_at: "invalid"
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(situation.tasks.order(:position)).to eq([first_task, second_task, third_task])
    end

    it "1未満の順番では並べ替えを行わない" do
      expect_any_instance_of(Task).not_to receive(:insert_at)

      patch situation_position_path(situation), params: {
        task_id: first_task.id,
        insert_at: 0
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(situation.tasks.order(:position)).to eq([first_task, second_task, third_task])
    end
  end
end
