json.partial! 'user', user: @user
json.affiliateKey @user.affiliate_key
json.referrals do
  json.tier1 @user.affiliates.select{ |a| a.level == 1}.count
  json.tier2 @user.affiliates.select{ |a| a.level == 2}.count
  json.tier3 @user.affiliates.select{ |a| a.level == 3}.count
  json.total @user.affiliates.count
end
json.timeframe do
  json.day @user.affiliates.select { |a| a.created_at > 24.hours.ago }.count
  json.week @user.affiliates.select { |a| a.created_at > 7.days.ago }.count
  json.month @user.affiliates.select { |a| a.created_at > 30.days.ago }.count
  json.quarter @user.affiliates.select { |a| a.created_at > 90.days.ago }.count
end
json.earnings do
  json.balance @user.affiliate_balance.to_f
  json.total @user.affiliate_earnings.to_f
  json.masternodes @user.affiliates.map(&:affiliate_user).map(&:nodes).flatten.reject { |n| ['reserved', 'sold'].include?(n.status) }.count
end
