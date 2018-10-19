FactoryBot.define do
  factory :account do
    user
    crypto
    balance "9.99"
    cached_crypto_symbol "MyString"
    cached_crypto_name "MyString"
  end
end
