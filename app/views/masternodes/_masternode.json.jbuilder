json.annualRoi masternode.yearly_roi[:value]
json.annualRoiPercentage masternode.yearly_roi[:percentage]
json.availableSupply masternode.available_supply
json.description masternode.description
json.firstRewardDays masternode.first_reward_days
json.liquidity do
  json.buy masternode.buy_liquidity
  json.sell masternode.sell_liquidity
end
json.marketCap masternode.market_cap
json.monthlyRoiValue masternode.monthly_roi[:value]
json.monthlyRoiPercentage masternode.monthly_roi[:percentage]
json.name masternode.name
json.nodePrice masternode.node_price
json.profile masternode.profile
json.purchasableStatus masternode.purchasable_status
json.slug masternode.slug
json.symbol masternode.symbol
json.totalSupply masternode.total_supply
json.url masternode.url
json.volume masternode.volume
json.token @user.generate_token if @user.present?
