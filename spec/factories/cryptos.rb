FactoryBot.define do
  factory :crypto do
    sequence(:symbol) { |n| "MN#{n}" }
    sequence(:name) { |n| "Masternode Coin #{n}" }
    daily_reward Random.rand(1..100)
    
    factory :dash do
      symbol "DASH"
      name "Dash"
    end

    factory :bitcoin do
      symbol 'BTC'
      name 'bitcoin'
      status 'active'
    end

    factory :crypto_with_price do
      after(:create) do |crypto|
        FactoryBot.create(:crypto_price, crypto: crypto, amount: 10, price_type: 'buy')
      end
    end
  end
end
