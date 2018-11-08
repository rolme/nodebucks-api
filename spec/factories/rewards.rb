FactoryBot.define do
  factory :reward do
    node
    timestamp Faker::Date.between(20.days.ago, Date.today)
    amount Random.rand(1..100)
    fee Random.rand(1..10)
  end
end
