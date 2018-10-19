class AddNbFinancialsToNode < ActiveRecord::Migration[5.2]
  def change
    add_column :nodes, :nb_buy_amount, :decimal, default: 0.0
    add_column :nodes, :nb_sell_amount, :decimal, default: 0.0
  end
end
