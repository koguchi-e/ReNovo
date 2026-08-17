# frozen_string_literal: true

require "rails_helper"

RSpec.describe Situation, type: :model do
  describe "バリデーション" do
    it "状況、問題、目標を入力して登録する" do
      situation = build(:situation)
      expect(situation).to be_valid
    end

    it "状況、問題、目標が空欄だと登録できない" do
      situation = build(:situation, fact: nil, problem: nil, goal: nil)
      expect(situation).not_to be_valid
    end

    it "状況、問題、目標が300文字以内なら登録できる" do
      situation = build(
        :situation,
        fact: "あ" * 300,
        problem: "あ" * 300,
        goal: "あ" * 300
      )
      expect(situation).to be_valid
    end

    it "状況、問題、目標が301文字だと登録できない" do
      situation = build(
        :situation,
        fact: "あ" * 301,
        problem: "あ" * 301,
        goal: "あ" * 301
      )
      expect(situation).not_to be_valid
    end
  end

  describe "generation_timed_out?" do
    context "pendingで5分以上経過している場合" do
      it "trueを返す" do
        situation = create(
          :situation,
          status: :pending,
          created_at: 6.minutes.ago
        )
        expect(situation.generation_timed_out?).to be true
      end
    end

    context "pendingで5分経過していない場合" do
      it "falseを返す" do
        situation = create(
          :situation,
          status: :pending,
          created_at: 4.minutes.ago
        )
        expect(situation.generation_timed_out?).to be false
      end
    end

    context "completedの場合" do
      it "falseを返す" do
        situation = create(
          :situation,
          status: :completed,
          created_at: 6.minutes.ago
        )
        expect(situation.generation_timed_out?).to be false
      end
    end
  end
end
