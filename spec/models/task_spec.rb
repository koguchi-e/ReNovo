require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "バリデーション" do
    it "タスクを入力して登録できる" do
      task = build(:task)
      expect(task).to be_valid
    end
    it "タスクが空欄だと登録できない" do
      task = build(:task, content: nil, position: nil)
      expect(task).not_to be_valid
    end
  end
end
