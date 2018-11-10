class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.references :user, foreign_key: true
      t.string :key, null: false
      t.string :value, null: false
      t.string :description

      t.timestamps
    end
  end
end
