json.affiliateBalance withdrawal.affiliate_balance.floor(2)
json.admin do
  json.partial! 'users/creator', user: withdrawal.admin if withdrawal.admin.present?
end
json.amount do
  json.btc '%.4f' % withdrawal.amount_btc.floor(4)
  json.usd '%.2f' % withdrawal.amount_usd.floor(2)
end
json.balances withdrawal.balances.each do |balance|
  json.btc balance["BTC"]
  json.hasNodes balance["has_nodes"]
  json.name balance["name"]
  json.slug balance["slug"]
  json.symbol balance["symbol"]
  json.usd balance["USD"]
  json.value balance["value"]
  json.withdrawable balance["withdrawable"]
end
json.cancelledAt withdrawal.cancelled_at&.to_formatted_s(:db)
json.createdAt withdrawal.created_at.to_formatted_s(:db)
json.destination withdrawal.destination
json.id withdrawal.id
json.processedAt withdrawal.processed_at&.to_formatted_s(:db)
json.slug withdrawal.slug
json.status withdrawal.status
json.user do
  json.partial! 'users/owner', user: withdrawal.user
end
json.transactions withdrawal.transactions.each do |transaction|
  json.amount transaction.amount.floor(5)
  json.notes transaction.notes
  json.slug transaction.slug
  json.status transaction.status
  json.symbol transaction.symbol
  json.type transaction.txn_type
  json.userEmail transaction.account ? transaction.account.user.email : withdrawal.user.email
  json.userName transaction.account ? transaction.account.user.full_name : withdrawal.user.full_name
  json.id transaction.id
  json.createdAt transaction.created_at.to_formatted_s(:db)
end
json.updatedAt withdrawal.updated_at&.to_formatted_s(:db)
