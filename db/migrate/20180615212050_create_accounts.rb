class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key: true
      t.references :crypto, foreign_key: true
      t.string :slug
      t.string :wallet
      t.decimal :balance, default: 0.0
      t.string :cached_crypto_symbol
      t.string :cached_crypto_name

      t.timestamps
    end
  end
end
