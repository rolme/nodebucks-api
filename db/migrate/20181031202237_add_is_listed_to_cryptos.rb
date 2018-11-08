class AddIsListedToCryptos < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :is_listed, :boolean, default: false
  end
end
