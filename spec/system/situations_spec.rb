require 'rails_helper'

RSpec.describe "Situations", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in_as(user)
  end

  scenario "ユーザーが振り返りを作成できる" do
    visit new_situation_path

    fill_in "situation_fact", with: "会議で進捗報告をしたが、うまく説明できなかった。"
    find('[data-testid="fact-next-button"]').click

    fill_in "situation_problem", with: "話す内容が整理できておらず、自信を持って説明できない。"
    find('[data-testid="problem-next-button"]').click

    fill_in "situation_goal", with: "次回の会議では要点を整理して説明できるようになりたい。"
    click_button "送信"

    # expect(page).to have_content "会議で進捗報告をしたが、うまく説明できなかった。"
    # expect(page).to have_content "話す内容が整理できておらず、自信を持って説明できない。"
    # expect(page).to have_content "次回の会議では要点を整理して説明できるようになりたい。"
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

  scenario "作成したふりかえりが一覧画面に表示される" do
    situation = FactoryBot.create(:situation, user: user)

    visit situations_path
    expect(page).to have_content situation.fact

    click_link situation.fact
    expect(page).to have_content situation.fact
    expect(page).to have_content situation.problem
    expect(page).to have_content situation.goal
  end
end
