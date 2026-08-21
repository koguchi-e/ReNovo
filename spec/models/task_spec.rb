# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  describe "バリデーション" do
    it "タスクを入力して登録できる" do
      task = build(:task)
      expect(task).to be_valid
    end

    it "contentが空欄だと登録できない" do
      task = build(:task, content: nil)
      expect(task).not_to be_valid
    end
  end

  describe "並び順" do
    it "同じ状況整理の末尾にpositionを自動設定する" do
      situation = create(:situation)
      first_task = create(:task, situation: situation, position: nil)
      second_task = create(:task, situation: situation, position: nil)

      expect(first_task.position).to eq(1)
      expect(second_task.position).to eq(2)
    end

    it "状況整理ごとにpositionを設定する" do
      first_situation = create(:situation)
      second_situation = create(:situation)

      create(:task, situation: first_situation, position: nil)
      task = create(:task, situation: second_situation, position: nil)

      expect(task.position).to eq(1)
    end
  end
end
