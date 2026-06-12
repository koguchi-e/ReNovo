require 'rails_helper'

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
  end
end
