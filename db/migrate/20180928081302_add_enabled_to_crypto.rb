class AddEnabledToCrypto < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :enabled, :boolean, default: true
  end
end
