class AddFeeToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :fee, :decimal, default: 0
  end
end
