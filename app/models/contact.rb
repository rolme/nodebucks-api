class Contact < ApplicationRecord
  belongs_to :reviewer, foreign_key: :reviewed_by_user, class_name: 'User', optional: true

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  after_create :send_email

  scope :unreviewed, -> { where(reviewed_at: nil) }

  private

  def send_email
    SupportMailer.send_email("#{self.email} contacted Nodebucks", self.message).deliver_later
  end
end
