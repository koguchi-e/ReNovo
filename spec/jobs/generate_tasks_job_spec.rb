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
      expect(situation.reload).to be_completed
      expect(situation.tasks.order(:position).pluck(:content)).to eq(tasks)
      expect(situation.tasks.order(:position).pluck(:position)).to eq([ 1, 2, 3, 4, 5 ])
    end

    it "生成結果が5件ではない場合、statusをfailedにする" do
      situation = create(:situation, status: :pending)
      allow(TaskGenerationAgent).to receive(:generate).and_return([ "1件のみのタスク" ])
      described_class.perform_now(situation_id: situation.id)
      expect(situation.reload).to be_failed
    end

    it "生成結果が配列ではない場合、statusをfailedにする" do
      situation = create(:situation, status: :pending)
      allow(TaskGenerationAgent).to receive(:generate).and_return("配列ではないタスク")
      described_class.perform_now(situation_id: situation.id)
      expect(situation.reload).to be_failed
    end

    it "生成結果がnilの場合、statusをfailedにする" do
      situation = create(:situation, status: :pending)
      allow(TaskGenerationAgent).to receive(:generate).and_return(nil)
      described_class.perform_now(situation_id: situation.id)
      expect(situation.reload).to be_failed
    end

    it "生成結果が空文字が含まれる場合、statusをfailedにする" do
      situation = create(:situation, status: :pending)
      tasks = [
        "",
        "資格試験の問題を1問だけ解く",
        "間違えた問題の解説を5分読む",
        "明日解く問題のページに付箋を貼る",
        "勉強時間をカレンダーに30分だけ登録する"
      ]
      allow(TaskGenerationAgent).to receive(:generate).and_return(tasks)
      described_class.perform_now(situation_id: situation.id)
      expect(situation.reload).to be_failed
    end

    it "例外が発生した場合、statusをfailedにする" do
      situation = create(:situation, status: :pending)
      allow(TaskGenerationAgent).to receive(:generate).and_raise(StandardError, "AI Error")
      expect {
        described_class.perform_now(situation_id: situation.id)
      }.to raise_error(StandardError, "AI Error")
      expect(situation.reload).to be_failed
    end
  end
end
