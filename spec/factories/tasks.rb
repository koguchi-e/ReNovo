FactoryBot.define do
  factory :task do
    association :situation
    content { "明日以降のスケジュールを書き、空き時間を確保する" }
    position { 1 }
  end
end
