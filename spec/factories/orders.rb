FactoryBot.define do
  factory :order do
    user
    node
    order_type  [:buy, :sold].sample
    status [:paid, :unpaid, :canceled].sample
  end
end
