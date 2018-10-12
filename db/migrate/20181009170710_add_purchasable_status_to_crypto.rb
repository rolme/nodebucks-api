class AddPurchasableStatusToCrypto < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :purchasable_status, :string, default: 'Unavailable'
    remove_column :cryptos, :enabled, :boolean, default: true
  end
end
