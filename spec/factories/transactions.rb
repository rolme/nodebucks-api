FactoryBot.define do
  factory :transaction do
    account
    reward
    txn_type [:deposit, :transfer, :withdraw].sample
    amount Random.rand(1..100)
    status [:pending, :processed, :cancelled].sample
    sequence(:notes) { |n| "Notes #{n}" }
  end
end
