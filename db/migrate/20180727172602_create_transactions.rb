class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :account, foreign_key: true
      t.references :reward, foreign_key: true, optional: true
      t.references :withdrawal, foreign_key: true, optional: true
      t.string :txn_type
      t.string :slug
      t.decimal :amount
      t.string :cached_crypto_name
      t.string :cached_crypto_symbol
      t.string :notes
      t.string :status, default: 'pending'
      t.datetime :cancelled_at
      t.datetime :processed_at
      t.integer :last_modified_by_admin_id

      t.timestamps
    end
  end
end
