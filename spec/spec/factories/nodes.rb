FactoryBot.define do
  factory :node do
    user nil
    crypto nil
    status "MyString"
    ip "MyString"
    cost "9.99"
    created_by_admin_id 1
    online_at "2018-06-15 14:20:51"
    sold_at "2018-06-15 14:20:51"
    version "MyString"
    last_upgraded_at "2018-06-15 14:20:51"
    vps_provider "MyString"
    vps_url "MyString"
    vps_monthly_cost "9.99"
  end
end
