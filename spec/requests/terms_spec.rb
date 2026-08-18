# frozen_string_literal: true

require "rails_helper"

RSpec.describe "利用規約", type: :request do
  describe "GET /terms" do
    it "未ログインでも閲覧できる" do
      get terms_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("利用規約")
    end
  end
end
