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

    Rails.logger.info ">>>>>> initial fee: #{fee}" if false
    tiers = [tier1, tier2, tier3].reject{ |tier| tier.blank? }
    tiers.each do |upline|
      percentage       = reward_percentages.shift
      fee             -= reward.fee * percentage
      upline_account   = Account.find_by(user_id: upline.id, crypto_id: node.crypto_id)
      upline_account ||= Account.create(user_id: upline.id, crypto_id: node.crypto_id)
      amount           = reward.fee * percentage


      if (false)
        Rails.logger.info ">>>>>> Coin: #{reward.name}"
        Rails.logger.info ">>>>>> percentage: #{percentage}"
        Rails.logger.info ">>>>>> remaining fee: #{fee}"
        Rails.logger.info ">>>>>> upline amount: #{amount}"
      end

      # Deposit reward
      upline_txn = upline_account.transactions.create(amount: amount, reward_id: reward.id, txn_type: 'deposit', notes: "Affiliate reward")
      upline_account.update_attribute(:balance, upline_account.balance + amount)
      upline_txn.update_attribute(:status, 'processed')

      # Convert reward to USD
      upline_txn = upline_account.transactions.create(amount: amount, reward_id: reward.id, txn_type: 'transfer', notes: "Transfer affiliate reward to affiliate earnings (USD)")
      usdt = CryptoPrice.find_by(amount: 25, crypto_id: node.crypto_id).usdt
      amount_usdt = amount * usdt

      if (false)
        Rails.logger.info ">>>>>> Conversion to USDT"
        Rails.logger.info ">>>>>> USDT coversion: #{usdt}"
        Rails.logger.info ">>>>>> converted amount ($USDT): #{amount_usdt}"
      end

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

    system_txn = system_account.transactions.create(amount: fee, reward_id: reward.id, txn_type: 'deposit', notes: 'Fee deposit (hosting fee)')
    # NOTE: this was to ensure admin transfers fees. We will do something else to audit this instead.
    # system_account.transactions.create(amount: fee, reward_id: reward.id, txn_type: 'transfer', notes: "#{reward.fee} #{reward.symbol} fee (minus #{reward.fee - fee} affiliate rewards) transfer from #{reward.node.wallet} to Nodebucks")

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
    btc                = account_balance["btc"]
    usd                = account_balance["usd"]
    fee_percentage     = (withdrawal.payment_type == 'paypal') ? account.crypto.percentage_hosting_fee * 2 : account.crypto.percentage_hosting_fee
    fee                = balance * fee_percentage
    symbol             = account.symbol

    account_txn        = account.transactions.create(amount: balance, cached_crypto_symbol: symbol, withdrawal_id: withdrawal.id, txn_type: 'withdraw', notes: "Account withdrawal of #{balance} #{account.symbol} (includes #{fee} #{account.symbol} fee)")
    system_fee_txn     = system_account.transactions.create(amount: fee, cached_crypto_symbol: symbol, withdrawal_id: withdrawal.id, txn_type: 'deposit', notes: "Fee deposit (#{fee} #{account.symbol})")
    system_balance_txn = system_account.transactions.create(amount: balance - fee, cached_crypto_symbol: symbol, withdrawal_id: withdrawal.id, txn_type: 'deposit', notes: "Balance deposit (#{balance - fee} #{account.symbol})")

    # TODO: Move into its own method
    wallet_amounts = withdrawal.user.node_wallet_withdrawals(account.crypto_id)
    note  = "#{balance} #{account.symbol} balance transfer to Nodebucks #{account.symbol} wallet<br/>"
    note += "<ul>"
    wallet_amounts.each do |wallet|
      note += "<li><a href='#{wallet[:url]}' target='_new'>#{wallet[:wallet]}</a> - #{wallet[:balance]}</li>"
    end
    note += "</ul>"

    system_account.transactions.create(amount: balance, cached_crypto_symbol: symbol, withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: note)
    system_account.transactions.create(amount: btc, cached_crypto_symbol: symbol, withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: "#{balance - fee} #{account.symbol} convert to BTC")

    if (withdrawal.payment_type == 'paypal')
      system_account.transactions.create(amount: usd, cached_crypto_symbol: 'BTC', withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: "#{'%.5f' % btc.to_f.floor(5)} BTC convert to USD")
      system_account.transactions.create(amount: usd, cached_crypto_symbol: 'USD', withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: "$#{'%.2f' % usd.to_f.floor(2)} USD transfer to #{withdrawal.target}")
    else # NOTE: assume its 'BTC'
      system_account.transactions.create(amount: btc, cached_crypto_symbol: 'BTC', withdrawal_id: withdrawal.id, txn_type: 'transfer', notes: "#{'%.5f' % btc.to_f.floor(5)} BTC transfer to #{withdrawal.target}")
    end

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
    txn = Transaction.create(amount: balance, cached_crypto_symbol: 'USD', withdrawal_id: withdrawal.id, txn_type: 'withdraw', notes: "Affiliate reward withdrawal of $#{balance}")

    Account.transaction do
      withdrawal.user.update_attribute(:affiliate_balance, user.affiliate_balance - balance)
      txn.update_attribute(:status, 'processed')
    end
  end
end
