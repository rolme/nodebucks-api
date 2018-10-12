json.btcWallet user.btc_wallet
json.email user.email
json.first user.first
json.fullName user.full_name
json.last user.last
json.slug user.slug
json.balances user.balances.each do |balance|
  json.fee balance[:fee]
  json.hasNodes balance[:has_nodes]
  json.name balance[:name]
  json.slug balance[:slug]
  json.symbol balance[:symbol]
  json.usd balance[:usd]
  json.value balance[:value]
  json.wallet balance[:wallet]
end
