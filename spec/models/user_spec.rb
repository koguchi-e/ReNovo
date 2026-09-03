# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe ".find_or_create_from_auth_hash" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email_address: "test@example.com",
          name: "テスト太郎"
        }
      )
    end

    context "未登録ユーザーの場合" do
      it "認証情報からユーザーを作成して返す" do
        expect do
          user = described_class.find_or_create_from_auth_hash(auth)

          expect(user).to have_attributes(
            provider: "google_oauth2",
            uid: "123456789",
            email_address: "test@example.com",
            name: "テスト太郎"
          )
        end.to change(described_class, :count).by(1)
      end
    end

    context "登録済みユーザーの場合" do
      it "同じproviderとuidのユーザーを返し、新規作成しない" do
        existing_user = create(
          :user,
          provider: auth.provider,
          uid: auth.uid
        )

        expect do
          user = described_class.find_or_create_from_auth_hash(auth)
          expect(user).to eq(existing_user)
        end.not_to change(described_class, :count)
      end
    end

    context "uidが同じでproviderが異なる場合" do
      it "別のユーザーを作成する" do
        create(:user, provider: "other_provider", uid: auth.uid)

        expect do
          described_class.find_or_create_from_auth_hash(auth)
        end.to change(described_class, :count).by(1)
      end
    end

    context "providerが同じでuidが異なる場合" do
      it "別のユーザーを作成する" do
        create(:user, provider: auth.provider, uid: "other_uid")

        expect do
          described_class.find_or_create_from_auth_hash(auth)
        end.to change(described_class, :count).by(1)
      end
    end
  end

  describe "#monthly_usage_limit_reached?" do
    it "今月のSituationが50件ならtrueを返す" do
      user = create(:user)
      create_list(:situation, 50, user: user)

      expect(user.monthly_usage_limit_reached?).to be(true)
    end
  end
end
