json.array! @rewards.each do |reward|
  json.timestamp reward.timestamp.to_formatted_s(:db)
  json.crypto reward.name
  json.symbol reward.symbol
  json.amount reward.total_amount.floor(4)
end
