# frozen_string_literal: true

require "rails_helper"

RSpec.describe "タスク生成状態の再確認", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in_as(user)
  end

  context "Situationがgeneratingの場合" do
    let(:situation) { FactoryBot.create(:situation, user: user, status: :generating) }
    it "完了配信を受信できなくてもタスク一覧に切り替わる" do
      visit situation_tasks_path(situation)

      expect(page).to have_content("タスクを作成しています")

      5.times do |index|
        situation.tasks.create!(
          content: "タスク#{index + 1}",
          position: index + 1
        )
      end

      situation.completed!
      expect(page).to have_content("タスク1", wait: 10)
      expect(page).to have_content("タスク5")
      expect(page).not_to have_content("Loading")
    end
  end

  context "Situationがfailedの場合" do
    let(:situation) { FactoryBot.create(:situation, user: user, status: :failed) }
    it "再生成ボタンを押すと生成中画面に切り替わり、完了後にタスク一覧を表示する" do
      visit situation_tasks_path(situation)
      expect(page).to have_content("タスクの作成に失敗しました。")

      click_button "もう一度タスクを生成する"

      expect(page).to have_content("タスクを作成しています")
      expect(situation.reload).to be_generating

      5.times do |index|
        situation.tasks.create!(
          content: "タスク#{index + 1}",
          position: index + 1
        )
      end
      situation.completed!

      expect(page).to have_content("タスク1", wait: 10)
      expect(page).to have_content("タスク5")
      expect(page).not_to have_content("もう一度タスクを生成する")
      expect(page).not_to have_content("Loading")
    end
  end
end
