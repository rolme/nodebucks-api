FactoryBot.define do
  factory :withdrawal do
    user
    amount_btc Random.rand(1..100)
    status [:pending, :processed, :reserved].sample

    factory :user_with_subscription do
      after(:create) do |withdrawal|
        FactoryBot.create(:bitcoin, withdrawal: withdrawal)
      end
    end

    factory :withdrawal_with_transactions do
      after(:create) do |withdrawal|
        FactoryBot.create_list(:transaction, 4, withdrawal: withdrawal)
      end
    end
  end
end
