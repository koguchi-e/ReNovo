require 'rails_helper'

RSpec.describe "タスク生成状態の再確認", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let!(:situation) { FactoryBot.create(:situation, user: user, status: :generating) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in_as(user)
  end

  it "完了配信を受信できなくてもタスク一覧に切り替わる" do
    visit situation_tasks_path(situation)

    expect(page).to have_content("Loading")

    5.times do |index|
      situation.tasks.create!(
        content: "タスク#{index+1}",
        position: index + 1
      )
    end

    situation.completed!
    expect(page).to have_content("タスク1", wait: 10)
    expect(page).to have_content("タスク5")
    expect(page).not_to have_content("Loading")
  end
end
