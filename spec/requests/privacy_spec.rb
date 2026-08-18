# frozen_string_literal: true

require "rails_helper"

RSpec.describe "プライバシーポリシー", type: :request do
  describe "GET /privacy" do
    it "未ログインでも閲覧できる" do
      get privacy_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("プライバシーポリシー")
    end
  end
end
