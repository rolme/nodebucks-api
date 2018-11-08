json.buyPrice node.cost
json.buyProfit node.buy_profit
json.cost node.cost # Need to remove cost and use buyPrice/buy_price
json.createdAt node.created_at.to_formatted_s(:db)
json.creator do
  json.partial! 'users/creator', user: node.creator if node.creator.present?
end
json.crypto do
  json.partial! 'cryptos/crypto', crypto: node.crypto
end
json.deletedAt node.deleted_at&.to_formatted_s(:db)
json.duplicatedIp node.duplicated_ip?
json.duplicatedWallet node.duplicated_wallet?
json.events node.events.sort { |e1, e2| e2.timestamp <=> e1.timestamp }.each do |event|
  json.id event.id
  json.timestamp event.timestamp.to_formatted_s(:db)
  json.type event.event_type
  json.description event.description
  json.value event.value
end
json.explorerUrl "#{node.explorer_url}#{node.wallet}"
json.flatSetupFee node.flat_setup_fee
json.id node.id + 10000
json.ip node.ip
json.isReady node.ready?
json.lastUpgradedAt node.last_upgraded_at&.to_formatted_s(:db)
json.nodebucksBuyAmount node.nb_buy_amount
json.nodebucksSellAmount node.nb_sell_amount
json.onlineAt node.online_at&.to_formatted_s(:db)
json.owner do
  json.partial! 'users/owner', user: node.user
end
json.rewardSetting node.reward_setting # TODO: Move this from Node to Account
json.rewardTotal node.reward_total
json.rewards do
  json.week node.week_reward
  json.quarter node.quarter_reward
  json.month node.month_reward
  json.year node.year_reward
end
json.sellBitcoinWallet node.sell_bitcoin_wallet
json.sellPrice node.sell_price # TODO: This is a duplicate of json.value
json.sellPriceBTC node.sell_price_btc.floor(4)
json.sellProfit node.sell_profit.floor(2)
json.sellSetting node.sell_setting
json.slug node.slug
json.soldAt node.sold_at&.to_formatted_s(:db)
json.status node.status
json.stripe node.stripe
json.timeLimit Node::TIME_LIMIT.to_i
json.totalFees node.total_fees
json.totalFeesCollected node.total_fees_collected
json.uptime node.uptime
json.wallet node.wallet
json.withdrawWallet node.withdraw_wallet
json.value (node.sell_price.blank?) ? node.value : node.sell_price # TODO: This is a duplicate of json.sellPrice
json.values node.node_prices.each do |price|
  json.timestamp price.created_at.to_formatted_s(:db)
  json.value price.value
end
json.version node.version
json.vpsMonthlyCost node.vps_monthly_cost
json.vpsProvider node.vps_provider
json.vpsUrl node.vps_url
json.exchanges_available node.crypto.exchanges_available
