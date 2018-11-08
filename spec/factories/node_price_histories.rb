FactoryBot.define do
  factory :node_price_history do
    node
    value Random.rand(1000000..9999999)
  end
end
