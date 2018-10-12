class AddTwoFaSecretToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :two_fa_secret, :string
  end
end
