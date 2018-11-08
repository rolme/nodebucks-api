json.amount order.amount
json.currency order.currency
json.description order.description
json.user do
  json.partial! 'users/basic', user: order.user
end
json.node do
  json.partial! 'nodes/basic', node: order.node if order.node.present?
end
json.fee order.fee
json.orderId order.slug
json.orderType order.order_type
json.paymentMethod order.payment_method
json.status order.status
json.slug order.slug
json.target order.target
