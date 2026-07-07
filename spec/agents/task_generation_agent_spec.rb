require 'rails_helper'

RSpec.describe TaskGenerationAgent do
  describe ".prompt_for" do
    it "situationの内容を含むプロンプトを作る" do
      situation = build(
        :situation,
        fact: "仕事が忙しい",
        problem: "学習時間が取れない、疲れて寝てしまう",
        goal: "資格試験合格、毎日30分勉強する"
      )
      prompt = described_class.prompt_for(situation)

      expect(prompt).to include("仕事が忙しい")
      expect(prompt).to include("学習時間が取れない、疲れて寝てしまう")
      expect(prompt).to include("資格試験合格、毎日30分勉強する")
    end
  end
  describe ".generate" do
    it "AIの返答からtasksを取り出して返す" do
      situation = build(
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
      response = instance_double("RubyLLM::Message", content: { tasks: tasks })
      agent = instance_double(TaskGenerationAgent, ask: response)
      allow(TaskGenerationAgent).to receive(:new).and_return(agent)

      expect(TaskGenerationAgent.generate(situation)).to eq(tasks)
    end
  end

  describe "SYSTEM_PROMPT" do
    it "生成ルールを含んでいる" do
      prompt = TaskGenerationAgent::SYSTEM_PROMPT
      expect(prompt).to include("タスクは5つだけ出力")
      expect(prompt).to include("医療的判断をしないでください")
      expect(prompt).to include("人生アドバイスをしないでください")
    end
  end
end
