json.balances User.system.balances.each do |balance|
  json.btc balance[:btc]
  json.fee balance[:fee]
  json.hasNodes balance[:has_nodes]
  json.name balance[:name]
  json.slug balance[:slug]
  json.symbol balance[:symbol]
  json.usd balance[:usd]
  json.value balance[:value]
  json.wallet balance[:wallet]
end
json.settings User.system.settings.each do |setting|
  json.key setting.key
  json.value setting.value
  json.description setting.description
end
json.unpaidAmount Order.unpaid_amount.ceil(2)
