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
  end
end
