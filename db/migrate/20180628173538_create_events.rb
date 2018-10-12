class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :node, foreign_key: true
      t.string :event_type
      t.string :description
      t.decimal :value, default: 0.0
      t.datetime :timestamp

      t.timestamps
    end
  end
end
