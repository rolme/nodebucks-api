json.affiliateKey user.affiliate_key
json.affiliateKeyCreatedAt user.affiliate_key_created_at.to_formatted_s(:db)
json.address user.address
json.admin user.admin? # NOTE: This info is not part of token (JWT)
json.avatar user.avatar
json.balances user.balances.each do |balance|
  json.btc balance[:btc]
  json.fee balance[:fee]
  json.hasNodes balance[:has_nodes]
  json.name balance[:name]
  json.slug balance[:slug]
  json.symbol balance[:symbol]
  json.usd balance[:usd]
  json.value balance[:value]
  json.wallet balance[:wallet]
  json.withdrawable balance[:withdrawable]
end
json.city user.city
json.confirmedAt user.confirmed_at&.to_formatted_s(:db)
json.country user.country
json.createdAt user.created_at.to_formatted_s(:db)
json.deletedAt user.deleted_at&.to_formatted_s(:db)
json.email user.email
json.enabled user.enabled
json.enabled2FA user.two_fa_secret.present?
json.first user.first
json.fullName user.full_name
json.id user.id
json.last user.last
json.newEmail user.new_email
json.nickname user.nickname
json.rewardNotificationOn user.reward_notification_on
json.slug user.slug
json.state user.state
json.updatedAt user.updated_at.to_formatted_s(:db)
json.zipcode user.zipcode
json.verified user.verified_at
json.verificationStatus user.verification_status
json.verificationImage user.verification_image
json.affiliates do
  json.tier1 user.upline(1)
  json.tier2 user.upline(2)
  json.tier3 user.upline(3)
end
