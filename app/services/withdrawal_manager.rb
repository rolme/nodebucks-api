class WithdrawalManager
  attr_accessor :withdrawal
  attr_reader :crypto, :error, :user

  def initialize(user, my_withdrawal=nil)
    @user         = user
    @withdrawal   = my_withdrawal
    @withdrawal ||= Withdrawal.find_by(user_id: user.id, status: :reserved)
    @withdrawal ||= Withdrawal.new(
      amount_btc: user.total_balance[:btc],
      amount_usd: user.total_balance[:usd],
      affiliate_balance: user.affiliate_balance,
      balances: user.balances,
      user_id: user.id,
      status: :reserved
    )
  end

  def confirm(params)
    if !user.authenticate(params[:password])
      @error = 'Incorrect password.'
      return false
    end

    if withdrawal.id.nil?
      @error = 'Please reserve a price first.'
      return false
    end

    if(params[:payment] == 'BTC')
      account = user.accounts.find{ |a| a.symbol == 'BTC' }
      if params[:wallet].blank? && account.wallet.blank?
        @error = 'BTC wallet not present. Please provide a withdrawal wallet.'
        return false
      end
      account.update_attribute(:wallet, params[:wallet]) if params[:wallet] != account.wallet
    elsif (params[:payment] == 'paypal')
      if params[:paypal_email].blank? && account.wallet.blank?
        @error = 'Please provide a paypal email address.'
        return false
      end
    end

    withdrawal.update_attributes(target: params[:target], payment_type: params[:payment_type])
    pending
  end

  def update(params)
    case params[:status]
    when 'processed'; process
    when 'cancelled'; cancel
    when 'pending'; pending
    end
    withdrawal
  end

  def save(timestamp=DateTime.current)
    if withdrawal.id.present?
      withdrawal.amount_btc = user.total_balance[:btc]
      withdrawal.amount_usd = user.total_balance[:usd]
      withdrawal.balances   = user.balances
    end

    if withdrawal.save
      withdrawal
    else
      @error = withdrawal.errors.full_messages.join(', ')
      false
    end
  end

protected

  def cancel
    @withdrawal.transactions.sort_by(&:id).reverse.each do |txn|
      txn.reverse!
    end

    @withdrawal.update_attributes(
      last_modified_by_admin_id: user.id,
      cancelled_at: DateTime.current,
      status: :cancelled
    )
  end

  def pending
    user = withdrawal.user
    user.accounts.reject{ |a| a.symbol == 'BTC' || a.balance == 0 }.each do |account|
      next unless account.crypto.withdrawable?

      tm = TransactionManager.new(account)
      tm.withdraw(withdrawal)
    end
    TransactionManager.withdraw_affiliate_reward(withdrawal) if user.affiliate_balance > 0
    @withdrawal.update_attribute(:status, :pending)
  end

  def process
    # TODO: It should get latest transactions and see if amount was processed
    #       before allowing it through
    @withdrawal.update_attributes(
      last_modified_by_admin_id: user.id,
      processed_at: DateTime.current,
      status: :processed
    )
  end

end
