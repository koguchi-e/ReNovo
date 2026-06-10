require 'rails_helper'

RSpec.describe Reflection, type: :model do
  describe "バリデーション" do
    it "状況、問題、目標を入力して登録する" do
      reflection = build(:reflection)
      expect(reflection).to be_valid
    end

    it "状況、問題、目標が空欄だと登録できない" do
      reflection = build(:reflection, situation: nil, problem: nil, goal: nil)
      expect(reflection).not_to be_valid
    end
  end
end
