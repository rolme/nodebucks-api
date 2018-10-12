class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :subject
      t.string :email
      t.text :message
      t.integer :reviewed_by_user, index: true
      t.datetime :reviewed_at

      t.timestamps
    end
  end
end
