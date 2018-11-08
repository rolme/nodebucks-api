FactoryBot.define do
  factory :affiliate do
    user
    association :affiliate_user, factory: :user
    level Random.rand(1..3)
  end
end
