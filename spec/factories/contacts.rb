FactoryBot.define do
  factory :contact do
    sequence(:subject) { |n| "Subject#{n}" }
    sequence(:email) { |n| "user#{n}@domain.com" }
    sequence(:message) { |n| "Message#{n}" }
  end
end
