FactoryBot.define do
  factory :account do
    user
    association :crypto, factory: :bitcoin
    balance Random.rand(0..1000)
    sequence(:wallet) { |n| "PFyM75zUNrVUcK5XDcaT4moRuKTsnDqWa#{n}" }

    factory :account_with_nodes do
      after(:create) do |account|
        FactoryBot.create_list(:node, 2, account: account)
      end
    end
  end
end
