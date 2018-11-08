FactoryBot.define do
  factory :crypto_price do
    crypto
    amount [1, 10, 25, 50, 100, 500, 1000, 2500, 5000, 10000].sample
    btc Random.rand(1..10)
    usdt Random.rand(1..10000)
  end
end
