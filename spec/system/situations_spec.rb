# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Situations", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in_as(user)
  end

  scenario "ユーザーが状況整理を行える" do
    visit new_situation_path

    fill_in "現在の状況", with: "会議で進捗報告をしたが、うまく説明できなかった。"
    find('[data-testid="fact-next-button"]').click

    fill_in "解決したい問題", with: "話す内容が整理できておらず、自信を持って説明できない。"
    find('[data-testid="problem-next-button"]').click

    fill_in "達成したい目標", with: "次回の会議では要点を整理して説明できるようになりたい。"
    click_button "タスクを作成する"

    visit situations_path

    expect(page).to have_content "会議で進捗報告をしたが、うまく説明できなかった。"
  end

  scenario "301文字以上は登録できない" do
    visit new_situation_path
    fill_in "situation_fact", with: "あ" * 301
    find('[data-testid="fact-next-button"]').click

    expect(page).to have_content "300文字以内にしてください。"
  end

  scenario "空欄では次に進めない" do
    visit new_situation_path
    fill_in "situation_fact", with: ""
    find('[data-testid="fact-next-button"]').click

    expect(page).to have_content "入力してください。"
  end

  scenario "状況整理の内容が一覧画面に表示される" do
    visit new_situation_path

    fill_in "現在の状況", with: "会議で進捗報告をしたが、うまく説明できなかった。"
    find('[data-testid="fact-next-button"]').click

    fill_in "解決したい問題", with: "話す内容が整理できておらず、自信を持って説明できない。"
    find('[data-testid="problem-next-button"]').click

    fill_in "達成したい目標", with: "次回の会議では要点を整理して説明できるようになりたい。"
    click_button "タスクを作成する"

    visit situations_path
    expect(page).to have_content "会議で進捗報告をしたが、うまく説明できなかった。"
  end

  scenario "状況整理の履歴がない時その旨とリンクが表示される" do
    visit situations_path
    expect(page).to have_content "まだ状況整理を行っていません。"
    expect(page).to have_link("状況整理を始める", href: new_situation_path)
  end
end
