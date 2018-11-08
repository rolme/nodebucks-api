class AddExchangesAvailableToCryptos < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :exchanges_available, :boolean, default: true
  end
end
