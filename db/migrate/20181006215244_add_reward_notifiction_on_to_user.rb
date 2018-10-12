class AddRewardNotifictionOnToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reward_notification_on, :boolean, default: true
  end
end
