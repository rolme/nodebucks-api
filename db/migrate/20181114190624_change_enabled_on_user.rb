class ChangeEnabledOnUser < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :enabled, :boolean, default: true
  end
end
