class AddNodeSellPriceBtcToNode < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :node_sell_price_btc, :decimal, default: 0.0
    add_column :nodes, :sell_price_btc, :decimal, default: 0.0
  end
end
