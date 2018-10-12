class AddDeletedAtToNode < ActiveRecord::Migration[5.2]
  def change
    add_column :nodes, :deleted_at, :datetime
  end
end
