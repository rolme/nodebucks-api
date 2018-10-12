class CreateCryptos < ActiveRecord::Migration[5.2]
  def change
    create_table :cryptos do |t|
      t.string :slug
      t.string :name
      t.string :symbol
      t.string :url
      t.string :logo_url
      t.string :status, default: 'active'
      t.integer :masternodes, limit: 8
      t.decimal :node_price, default: 0.0
      t.decimal :daily_reward
      t.string :description
      t.decimal :block_reward
      t.decimal :price, default: 0.0
      t.decimal :sellable_price, default: 0.0
      t.decimal :estimated_price, default: 0.0
      t.decimal :estimated_node_price, default: 0.0
      t.decimal :flat_setup_fee, default: 0.0
      t.decimal :percentage_setup_fee, default: 0.05
      t.decimal :percentage_hosting_fee, default: 0.0295
      t.decimal :percentage_conversion_fee, default: 0.03
      t.integer :stake, default: 1000
      t.decimal :purchasable_price, default: 0.0
      t.string :explorer_url
      t.string :ticker_url
      t.decimal :market_cap, precision: 15, scale: 1
      t.decimal :volume, precision: 15, scale: 1
      t.decimal :available_supply, precision: 15, scale: 1
      t.decimal :total_supply, precision: 15, scale: 1
      t.text :profile

      t.timestamps
    end
  end
end
