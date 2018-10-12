json.amount transaction.amount
json.cryptoName transaction.name
json.cryptoSymbol transaction.symbol
json.notes transaction.notes
json.rewardId transaction.reward_id
json.slug transaction.slug
json.status transaction.status
json.type transaction.txn_type
json.userEmail transaction.account ? transaction.account.user.email : transaction.withdrawal.user.email
json.userName transaction.account ? transaction.account.user.full_name : transaction.withdrawal.user.full_name
json.withdrawalId transaction.withdrawal_id
json.id transaction.id
json.createdAt transaction.created_at.to_formatted_s(:db)
