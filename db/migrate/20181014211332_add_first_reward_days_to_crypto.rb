class AddFirstRewardDaysToCrypto < ActiveRecord::Migration[5.2]
  def change
    add_column :cryptos, :first_reward_days, :integer, default: 0
  end
end
