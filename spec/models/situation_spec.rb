# frozen_string_literal: true

require "rails_helper"

RSpec.describe Situation, type: :model do
  describe "バリデーション" do
    it "状況、問題、目標を入力して登録する" do
      situation = build(:situation)
      expect(situation).to be_valid
    end

    %i[fact problem goal].each do |attribute|
      context "#{attribute}について" do
        it "空欄だと登録できない" do
          situation = build(:situation, attribute => nil)
          expect(situation).not_to be_valid
        end

        it "300文字なら登録できる" do
          situation = build(:situation, attribute => "あ" * 300)
          expect(situation).to be_valid
        end

        it "301文字だと登録できない" do
          situation = build(:situation, attribute => "あ" * 301)
          expect(situation).not_to be_valid
        end
      end
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
