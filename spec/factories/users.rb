FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    uid { SecureRandom.uuid }
    email_address { |n| "test#{n}@example.com" }
    name { "テスト太郎" }
  end
end
