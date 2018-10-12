class AddIdVerificationToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :verified_at, :datetime
    add_column :users, :verification_status, :string, default: 'none'
    add_column :users, :verification_image, :string
  end
end
