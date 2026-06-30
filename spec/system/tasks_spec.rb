require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let!(:situation) { FactoryBot.create(:situation, user: user) }
  let!(:task) { FactoryBot.create(:task, situation: situation) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in_as(user)
  end

  scenario "タスクを追加し、一覧に追加される" do
    visit situation_tasks_path(situation)
    find('[data-testid="open-task-form-button"]').click

    find('[data-testid="new-task-content-input"]').fill_in with: "新しいタスク"
    find('[data-testid="create-task-button"]').click

    expect(page).to have_content "新しいタスク"
  end

  scenario "タスクが空欄だと登録できない" do
    visit situation_tasks_path(situation)
    find('[data-testid="open-task-form-button"]').click

    find('[data-testid="new-task-content-input"]').fill_in with: ""
    find('[data-testid="create-task-button"]').click

    expect(page).to have_content "タスクの追加に失敗しました。"
  end

  scenario "タスクを更新し、一覧が変更される" do
    visit situation_tasks_path(situation)
    find('[data-testid="edit-task-button"]').click

    find('[data-testid="edit-task-content-input"]').fill_in with: "更新済タスク"
    find('[data-testid="update-task-button"]').click

    expect(page).to have_content "更新済タスク"
  end

  scenario "タスクを削除し、一覧から消える" do
    delete_task = create(:task, situation:, content: "削除するタスク")

    visit situation_tasks_path(situation)
    expect(page).to have_content "削除するタスク"

    accept_confirm "本当に削除しますか？" do
      find("[data-testid='delete-task-button-#{delete_task.id}']").click
    end

    expect(page).not_to have_content "削除するタスク"
  end
end
