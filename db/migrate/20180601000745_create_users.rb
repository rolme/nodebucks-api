class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :password_digest
      t.string :nickname
      t.boolean :admin, default: false
      t.boolean :accessible, default: true
      t.string :slug
      t.datetime :confirmed_at
      t.string :reset_token
      t.datetime :reset_at
      t.datetime :deleted_at
      t.string :new_email
      t.string :avatar
      t.string :facebook
      t.string :google
      t.string :linkedin
      t.string :address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.integer :upline_user_id
      t.decimal :affiliate_earnings, default: 0.0
      t.decimal :affiliate_balance, default: 0.0
      t.string :affiliate_key, index: { unique: true }
      t.datetime :affiliate_key_created_at

      t.timestamps
    end
  end
end
