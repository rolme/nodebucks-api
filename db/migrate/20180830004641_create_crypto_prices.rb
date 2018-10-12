class CreateCryptoPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :crypto_prices do |t|
      t.references :crypto, foreign_key: true
      t.integer :amount
      t.decimal :btc, default: 0.0
      t.decimal :usdt, default: 0.0
      t.string :price_type, default: 'buy'

      t.timestamps
    end
  end
end
