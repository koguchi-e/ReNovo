FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    uid { "123456789" }
    email_address { "test@example.com" }
    name { "テスト太郎" }
  end
end
