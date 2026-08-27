# frozen_string_literal: true

require "rails_helper"

RSpec.describe "利用規約", type: :request do
  describe "GET /terms" do
    it "未ログインでも閲覧できる" do
      get terms_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("利用規約")
    end

    it "サービスの出力を参考にした判断または行為に関する免責事項を表示する" do
      get terms_path

      expect(response.body).to include("医療または健康に関する情報")
      expect(response.body).to include("自傷、自殺、他者への危害または暴力")
      expect(response.body).to include("ユーザーは、自らの判断と責任において本サービスを利用する")
    end
  end
end
