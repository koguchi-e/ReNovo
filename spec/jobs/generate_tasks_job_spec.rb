require 'rails_helper'

RSpec.describe GenerateTasksJob, type: :job do
  describe "#perform" do
    it "タスクを5つ作成して、positionを割り振る" do
      situation = create(
        :situation,
        fact: "仕事が忙しい",
        problem: "学習時間が取れない、疲れて寝てしまう",
        goal: "資格試験合格、毎日30分勉強する"
      )
      tasks = [
        "帰宅後に机の上へ参考書を1冊置く",
        "資格試験の問題を1問だけ解く",
        "間違えた問題の解説を5分読む",
        "明日解く問題のページに付箋を貼る",
        "勉強時間をカレンダーに30分だけ登録する"
      ]
      allow(TaskGenerationAgent).to receive(:generate).and_return(tasks)
      expect {
        described_class.perform_now(situation_id: situation.id)
      }.to change(Task, :count).by(5)
      expect(situation.tasks.order(:position).pluck(:content)).to eq(tasks)
      expect(situation.tasks.order(:position).pluck(:position)).to eq([ 1, 2, 3, 4, 5 ])
    end
  end
end
