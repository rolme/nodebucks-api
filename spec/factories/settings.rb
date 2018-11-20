FactoryBot.define do
  factory :setting do
    user
    sequence(:key) { |n| "Key #{n}" }
    sequence(:value) { |n| "Value #{n}" }
    sequence(:description) { |n| "description #{n}" }
  end
end