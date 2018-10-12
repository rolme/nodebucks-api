class CreateNodePriceHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :node_price_histories do |t|
      t.references :node, foreign_key: true
      t.jsonb :data, null: false, default: {}
      t.string :source
      t.decimal :value, default: 0.0

      t.timestamps
    end
  end
end
