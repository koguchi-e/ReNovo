FactoryBot.define do
  factory :reflection do
    association :user

    situation { "仕事が忙しい" }
    problem { "学習時間が取れない、疲れて寝てしまう" }
    goal { "資格試験合格、毎日30分勉強する" }
  end
end
