class CreateNodeSellPriceHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :node_sell_price_histories do |t|
      t.references :crypto, foreign_key: true
      t.decimal :value, default: 0.0

      t.timestamps
    end
  end
end
