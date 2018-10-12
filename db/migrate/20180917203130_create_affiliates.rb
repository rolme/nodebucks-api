class CreateAffiliates < ActiveRecord::Migration[5.2]
  def change
    create_table :affiliates do |t|
      t.references :user, foreign_key: true
      t.integer :affiliate_user_id
      t.integer :level

      t.timestamps
    end
  end
end
