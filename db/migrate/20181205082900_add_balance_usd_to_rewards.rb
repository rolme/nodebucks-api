class AddBalanceUsdToRewards < ActiveRecord::Migration[5.2]
  def change
    add_column :rewards, :balance_usd, :decimal, default: 0
  end
end
