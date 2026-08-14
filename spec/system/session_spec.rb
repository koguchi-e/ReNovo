# frozen_string_literal: true

require "rails_helper"

RSpec.describe "セッション管理", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  scenario "ログインすると、ふりかえりの入力画面に遷移する" do
    visit root_path

    click_button "Googleでログイン"

    expect(page).to have_content "ログインしました。"
    expect(page).to have_content "今どんなことが起きていますか？"
  end

  scenario "ログアウトできる" do
    sign_in_as(user)

    find('[aria-label="メニューを開く"]').click
    click_link "ログアウト"

    expect(page).to have_current_path(root_path, ignore_query: true)
    expect(page).to have_content "ログアウトしました。"
    expect(page).to have_button "Googleでログイン"
  end
end
