FactoryBot.define do
  factory :transaction do
    account nil
    txn_type "MyString"
    slug "MyString"
    amount "9.99"
    cached_crypto_name "MyString"
    cached_crypto_symbol "MyString"
    notes "MyString"
    status "MyString"
    cancelled_at "2018-07-27 10:26:02"
    processed_at "2018-07-27 10:26:02"
    last_modified_by_admin_id 1
  end
end
