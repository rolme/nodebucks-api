class TransactionManager
  attr_reader :account, :system_account

  def initialize(account)
    @account = account
    @system_account = User.system.accounts.find { |a| a.crypto_id == account.crypto_id }
  end

  def deposit_reward(reward)
    node  = Node.find(reward.node_id)
    owner = node.user
    fee   = reward.fee

    tier1 = owner.upline
    tier2 = owner.upline(2)
    tier3 = owner.upline(3)

    reward_percentages = [0.2, 0.1, 0.05]
    tiers = [tier1, tier2, tier3].reject{ |tier| tier.blank? }
    tiers.each do |upline|
      percentage       = reward_percentages.shift
      fee             -= reward.fee * percentage
      upline_account   = Account.find_by(user_id: upline.id, crypto_id: node.crypto_id)
      upline_account ||= Account.create(user_id: upline.id, crypto_id: node.crypto_id)
      amount           = reward.fee * percentage

      # Deposit reward
      upline_txn = upline_account.transactions.create(amount: amount, reward_id: reward.id, txn_type: 'deposit', notes: "Affiliate reward")
      upline_account.update_attribute(:balance, upline_account.balance + amount)
      upline_txn.update_attribute(:status, 'processed')

      # Convert reward to USD
      upline_txn = upline_account.transactions.create(amount: amount, reward_id: reward.id, txn_type: 'transfer', notes: "Transfer affiliate reward to affiliate earnings (USD)")
      usdt = CryptoPrice.find_by(amount: 25, crypto_id: node.crypto_id).usdt
      upline_account.update_attribute(:balance, upline_account.balance - amount)
      upline.update_attributes(affiliate_earnings: upline.affiliate_earnings + amount * usdt, affiliate_balance: upline.affiliate_balance + amount * usdt)
      upline_txn.update_attribute(:status, 'processed')
    end

    auto_withdraw = reward.node.reward_setting == Node::REWARD_AUTO_WITHDRAWAL && reward.node.withdraw_wallet.present?
    if auto_withdraw
      system_account.transactions.create(amount: reward.total_amount, reward_id: reward.id, txn_type: 'transfer', notes: "#{reward.total_amount} #{reward.symbol} transfer from #{reward.node.wallet} to #{reward.node.withdraw_wallet}")
    else
      account_txn = account.transactions.create(amount: reward.total_amount, reward_id: reward.id, txn_type: 'deposit', notes: 'Reward deposit')
    end

    system_txn  = system_account.transactions.create(amount: fee, reward_id: reward.id, txn_type: 'deposit', notes: 'Fee deposit (hosting fee)')
    system_account.transactions.create(amount: fee, reward_id: reward.id, txn_type: 'transfer', notes: "#{reward.fee} #{reward.symbol} fee (minus #{reward.fee - fee} affiliate rewards) transfer from #{reward.node.wallet} to Nodebucks")

    Account.transaction do
      account.update_attribute(:balance, account.balance + reward.total_amount) unless auto_withdraw
      system_account.update_attribute(:balance, account.balance + fee)
      account_txn.update_attribute(:status, 'processed') unless auto_withdraw
      system_txn.update_attribute(:status, 'processed')
      reward.update_attribute(:balance, account.balance) unless auto_withdraw
    end

    SupportMailerService.send_auto_withdrawal_notification(reward.node.user, reward) if auto_withdraw
    SupportMailerService.send_user_balance_reached_masternode_price_notification(owner, node) if node.reward_setting == Node::REWARD_AUTO_BUILD && account.reload.balance >= node.stake
  end

  def withdraw(withdrawal)
    account_balance    = withdrawal.balances.find { |b| b["symbol"] == account.symbol }
    balance            = account_balance["value"].to_f
    fee                = balance * account.crypto.percentage_hosting_fee

    account_txn        = account.transactions.create(amount: balance, withdrawal_id: withdrawal.id, txn_type: 'withdraw', notes: "Account withdrawal of #{balance} #{account.symbol} (includes #{fee} #{account.symbol} fee)")
    system_fee_txn     = system_account.transactions.create(amount: fee, withdrawal_id: withdrawal.id, txn_type: 'deposit', notes: "Fee deposit (#{fee} #{account.symbol})")
    system_balance_txn = system_account.transactions.create(amount: balance - fee, withdrawal_id: withdrawal.id, txn_type: 'deposit', notes: "Balance deposit (#{balance - fee} #{account.symbol})")
    system_account.transactions.create(amount: balance, withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: "#{balance} #{account.symbol} balance transfer to Nodebucks (includes #{fee} #{account.symbol} fee)")
    system_account.transactions.create(amount: balance - fee, withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: "#{balance - fee} #{account.symbol} transfer to User #{withdrawal.user.email} [##{account.wallet} BTC wallet]")

    Account.transaction do
      account.update_attribute(:balance, account.balance - balance)
      system_account.update_attribute(:balance, system_account.balance + balance)
      system_balance_txn.update_attribute(:status, 'processed')
      system_fee_txn.update_attribute(:status, 'processed')
      account_txn.update_attribute(:status, 'processed')
    end
  end

  def self.withdraw_affiliate_reward(withdrawal)
    user = withdrawal.user
    balance = user.affiliate_balance
    txn = Transaction.create(amount: balance, withdrawal_id: withdrawal.id, txn_type: 'withdraw', notes: "Affiliate reward withdrawal of $#{balance}")

    Account.transaction do
      withdrawal.user.update_attribute(:affiliate_balance, user.affiliate_balance - balance)
      txn.update_attribute(:status, 'processed')
    end
  end
end
