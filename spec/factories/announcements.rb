FactoryBot.define do
  factory :announcement do
    sequence(:text) { |n| "Text#{n}" }
  end
end
