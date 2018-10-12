class AddPercentageDecommissionFeeToCrypto < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :percentage_decommission_fee, :decimal, default: 0.0
    add_column :cryptos, :node_sell_price, :decimal
  end
end
