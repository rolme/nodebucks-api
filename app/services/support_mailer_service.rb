class SupportMailerService
  def self.send_node_purchased_notification(user, node)
    SupportMailer.send_email(
      "User #{user.email} purchased new node server",
      "User #{user.email} purchased #{node.cached_crypto_name} node server."
    ).deliver_later
  end

  def self.send_node_sold_notification(user, node)
    SupportMailer.send_email(
      "User #{user.email} sold node server",
      "User #{user.email} sold #{node.cached_crypto_name} node server."
    ).deliver_later
  end

  def self.send_withdrawal_requested_notification(user, withdrawal)
    SupportMailer.send_email(
      "User #{user.email} requested new withdrawal",
      "User #{user.email} requested new withdrawal with btc amount: $ #{withdrawal.amount_btc} and usd amount : $ #{withdrawal.amount_usd}."
    ).deliver_later
  end

  def self.send_auto_withdrawal_notification(user, reward)
    SupportMailer.send_email(
      "User #{user.email} received a reward with auto withdrawal.",
      "User #{user.email} received new reward of #{reward.total_amount} #{reward.symbol} for auto withdrawal."
    ).deliver_later
  end

  def self.send_user_balance_reached_masternode_price_notification(user, node)
    SupportMailer.send_email(
      "#{user.email} account balance reached new node price",
      "#{user.email} account balance reached #{node.cached_crypto_name} node price."
    ).deliver_later
  end

  def self.send_node_offline_notification(node)
    SupportMailer.send_email(
      "#{node.cached_crypto_name} node is offline",
      "#{node.cached_crypto_name} node #{node.slug} with ip address: #{node.ip} is offline."
    ).deliver_later
  end

  def self.send_node_failed_ping_notification(node)
    SupportMailer.send_email(
      "#{node.cached_crypto_name} node failed ping. Server may be offline.",
      "#{node.cached_crypto_name} node #{node.slug} with ip address: #{node.ip} is #{node.status}. Please ping server to verify."
    ).deliver_later
  end
end
