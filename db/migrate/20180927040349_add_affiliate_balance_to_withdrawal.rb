class AddAffiliateBalanceToWithdrawal < ActiveRecord::Migration[5.2]
  def change
    add_column :withdrawals, :affiliate_balance, :decimal, default: 0.0
  end
end
