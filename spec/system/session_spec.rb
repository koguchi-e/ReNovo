# frozen_string_literal: true

require "rails_helper"

RSpec.describe "セッション管理", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  scenario "ログインすると、状況整理の入力画面に遷移する" do
    visit root_path

    click_button "Googleでログイン"

    expect(page).to have_content "ログインしました。"
    expect(page).to have_content "今、どんなことが"
    expect(page).to have_content "起きていますか？"
  end

  scenario "ログアウトできる" do
    sign_in_as(user)

    find('[aria-label="メニューを開く"]').click
    click_link "ログアウト"

    expect(page).to have_current_path(root_path, ignore_query: true)
    expect(page).to have_content "ログアウトしました。"
    expect(page).to have_button "Googleでログイン"
  end

  scenario "ログイン中のトップページに状況整理の操作を表示する" do
    sign_in_as(user)
    visit root_path

    expect(page).to have_link "新しく状況を整理する", href: new_situation_path
    expect(page).to have_link "状況整理の一覧", href: situations_path
  end

  scenario "メニューの外側をクリックするとメニューが閉じる" do
    sign_in_as(user)

    find('[aria-label="メニューを開く"]').click
    expect(page).to have_link("ログアウト", visible: true)

    find("main").click
    expect(page).not_to have_link("ログアウト", visible: true)
  end

  scenario "Escapeキーでメニューを閉じられる" do
    sign_in_as(user)

    menu_button = find('[aria-label="メニューを開く"]')
    menu_button.click
    page.send_keys(:escape)

    expect(page).not_to have_link("ログアウト", visible: true)
    expect(menu_button[:'aria-expanded']).to eq "false"
  end
end
