FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@domain.com"}
    password "password"
    password_confirmation "password"
    first "First"
    last "Last"
    nickname "Nick"

    factory :user_with_withdrawals do
      after(:create) do |user|
        FactoryBot.create_list(:withdrawal, 10, user: user)
      end
    end
  end

  factory :admin, class: User do
    last "Admin"
    admin true
  end
end
