class NodeOwnerMailer < ApplicationMailer
  def online(node)
    @node = node
    @user = node.user

    if @node.online_mail_sent_at.blank?
      mail(
        :content_type => "text/html",
        :subject => "Your #{@node.name.capitalize} masternode is online.",
        :to => (Rails.env.production?) ? @user.email : 'nodebucks.staging@gmail.com'
      )
      @node.update_attribute(:online_mail_sent_at, DateTime.current)
    end
  end

  def reward(reward)
    return unless reward.user_notification_setting_on && reward.notification_sent_at.blank?

    if !reward.node.user.reward_notification_on
      reward.update_attribute(:user_notification_setting_on, false)
    else
      @reward = reward
      @user   = reward.node.user
      @node   = reward.node
      @account_amount = reward.balance.round(5)
      mail(
        :content_type => "text/html",
        :subject => "Your #{reward.node.name.capitalize} masternode has received a reward.",
        :to => (Rails.env.production?) ? @user.email : 'nodebucks.staging@gmail.com'
      )
      reward.update_attribute(:notification_sent_at, DateTime.current)
    end
  end
end
