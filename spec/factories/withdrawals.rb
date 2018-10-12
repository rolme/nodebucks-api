FactoryBot.define do
  factory :withdrawal do
    user nil
    crypto nil
    balance "9.99"
    amount "9.99"
    status "MyString"
    last_modified_by_admin_id 1
    processed_at "2018-07-20 12:56:58"
    cancelled_at "2018-07-20 12:56:58"
  end
end
