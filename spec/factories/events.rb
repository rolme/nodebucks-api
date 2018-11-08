FactoryBot.define do
  factory :event do
    node
    event_type [:ops, :reward].sample
    sequence(:description) { |n| "Description #{n}" }
    value Random.rand(1..100)
  end
end
