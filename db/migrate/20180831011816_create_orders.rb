class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :node, foreign_key: true
      t.string :slug
      t.string :order_type
      t.decimal :amount
      t.string :currency
      t.string :status
      t.string :target
      t.string :description
      t.string :payment_method
      t.text :paypal_response

      t.timestamps
    end
  end
end
