class AddOnlineMailSentAtToNode < ActiveRecord::Migration[5.2]
  def change
    add_column :nodes, :online_mail_sent_at, :datetime
  end
end
