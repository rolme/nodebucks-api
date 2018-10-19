FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@domain.com"}
    password "password"
    password_confirmation "password"
    first "First"
    last "Last"
    nickname "Nick"
  end

  factory :admin, class: User do
    last "Admin"
    admin true
  end
end
