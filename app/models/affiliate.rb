class Affiliate < ApplicationRecord
  belongs_to :user
  belongs_to :affiliate_user, class_name: 'User'
end
