require "rails_helper"

RSpec.describe "Googleログイン", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario "ログインすると、ふりかえりの入力画面に遷移する" do
    visit root_path

    click_button "Googleでログイン"

    expect(page).to have_content "今どんなことが起きていますか？"
  end
end
