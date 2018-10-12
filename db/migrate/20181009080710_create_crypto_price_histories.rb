class CreateCryptoPriceHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :crypto_price_histories do |t|
      t.references :crypto, foreign_key: true
      t.decimal :circulating_supply
      t.decimal :total_supply
      t.decimal :max_supply
      t.decimal :price_usd
      t.decimal :volume_24h
      t.decimal :market_cap

      t.timestamps
    end
  end
end
