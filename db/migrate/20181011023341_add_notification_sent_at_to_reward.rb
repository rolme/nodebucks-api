class AddNotificationSentAtToReward < ActiveRecord::Migration[5.2]
  def change
    add_column :rewards, :notification_sent_at, :datetime
    add_column :rewards, :balance, :decimal, default: 0.0
    add_column :rewards, :node_reward_setting, :integer, default: 0
    add_column :rewards, :user_notification_setting_on, :boolean, default: true
  end
end
