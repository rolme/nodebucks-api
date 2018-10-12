class CreateRewards < ActiveRecord::Migration[5.2]
  def change
    create_table :rewards do |t|
      t.references :node, foreign_key: true
      t.string :cached_crypto_name
      t.string :cached_crypto_symbol
      t.datetime :timestamp
      t.string :txhash
      t.decimal :amount
      t.decimal :fee
      t.decimal :total_amount
      t.decimal :usd_value, default: 0.0

      t.timestamps
    end
  end
end
