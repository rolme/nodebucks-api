class AddBalanceToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :usd_value, :decimal
    add_column :transactions, :btc_value, :decimal
  end
end
