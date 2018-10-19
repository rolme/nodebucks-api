class AddEnabledToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :enabled, :boolean, default: false
  end
end
