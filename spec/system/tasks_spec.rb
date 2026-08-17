# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tasks", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let!(:situation) { FactoryBot.create(:situation, user: user, status: :completed) }
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

  scenario "状況整理の詳細に最初のタスクが表示される" do
    visit situation_path(situation)

    expect(page).to have_css "h2", text: "最初に取り組むタスク"
    expect(page).to have_css ".first-task__content", text: task.content
    expect(page).to have_css ".task-export__guidance", text: "終わったタスクは、左のチェックマークをクリックして完了にしましょう。"
    expect(page).to have_link "状況整理一覧に戻る", href: situations_path
  end

  scenario "状況整理の詳細でタスクを完了にできる" do
    visit situation_path(situation)

    find("[data-testid='compact-toggle-task-button-#{task.id}']").click

    expect(page).to have_current_path situation_path(situation)
    expect(page).to have_css ".compact-task-list__content.line-through", text: task.content
  end

  scenario "完了したタスクの次に取り組むタスクが表示される" do
    next_task = create(:task, situation: situation, position: 2, content: "次に進めるタスク")
    task.update!(completed: true)

    visit situation_path(situation)

    expect(page).to have_css "h2", text: "次に取り組むタスク"
    expect(page).to have_css ".first-task__content", text: next_task.content
    expect(page).not_to have_css ".first-task__content", text: task.content
  end

  scenario "状況整理の詳細からタスク追加へ移動すると追加フォームが開く" do
    situation_without_tasks = create(:situation, user: user, status: :failed)

    visit situation_path(situation_without_tasks)
    click_link "タスクを追加する"

    expect(page).to have_current_path(situation_tasks_path(situation_without_tasks, new_task: "open"))
    expect(page).not_to have_content "タスクの作成に失敗しました。"
    expect(page).not_to have_content "まずはタスクを1つ選んで始めてみましょう。"
    expect(page).to have_css "h3", text: "タスクの追加"
    expect(page).to have_css('[data-testid="new-task-content-input"]', visible: true)
    expect(page).to have_css('[data-testid="open-task-form-button"]', visible: false)
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
    task = create(:task, situation:, content: "削除するタスク")

    visit situation_tasks_path(situation)
    expect(page).to have_content "削除するタスク"

    accept_confirm "本当に削除しますか？" do
      find("[data-testid='delete-task-button-#{task.id}']").click
    end

    expect(page).not_to have_content "削除するタスク"
  end

  scenario "タスクを完了し、未完了に戻せる" do
    visit situation_tasks_path(situation)

    find("[data-testid='toggle-task-button-#{task.id}']").click
    expect(page).to have_css("p.line-through", text: task.content)

    find("[data-testid='toggle-task-button-#{task.id}']").click
    expect(page).not_to have_css("p.line-through", text: task.content)
  end

  scenario "完了済みタスクがある場合は次のタスクを案内する" do
    task.update!(completed: true)
    next_task = create(:task, situation: situation, position: 2, content: "次に取り組むタスク")

    visit situation_tasks_path(situation)

    expect(page).to have_css ".task-card__recommendation", text: "次はこれ"
    expect(page).to have_css ".task-list__item", text: next_task.content
    expect(page).not_to have_content "まずこれから"
  end
end
