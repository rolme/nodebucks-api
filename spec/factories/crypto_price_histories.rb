FactoryBot.define do
  factory :crypto_price_history do
    crypto
    circulating_supply Random.rand(1000000..9999999)
    total_supply Random.rand(1000000..9999999)
    max_supply Random.rand(1000000..9999999)
    price_usd Random.rand(100..99999)
    volume_24h Random.rand(1000000..999999999)
    market_cap Random.rand(1000000..999999999)
  end
end
