class AddSellLiquidityAnd < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :buy_liquidity, :boolean, default: true
    add_column :cryptos, :sell_liquidity, :boolean, default: true
  end
end
