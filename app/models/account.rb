class Account < ApplicationRecord
  include Sluggable

  belongs_to :user
  belongs_to :crypto

  has_many :nodes
  has_many :transactions

  validates :user_id, uniqueness: { scope: :crypto_id }

  delegate :slug,
           to: :crypto

  before_create :cache_values

  # NOTE: Allow for associating an account to a system user
  def user
    User.unscoped{ super }
  end

  def has_nodes?
    !nodes.where.not(status: ['disbursed', 'sold', 'reserved']).empty?
  end

  def name
    cached_crypto_name
  end

  def symbol
    cached_crypto_symbol
  end

  def cache_values(persist=false)
    crypto = Crypto.find(crypto_id)
    self.cached_crypto_name = crypto&.name
    self.cached_crypto_symbol = crypto&.symbol

    save! if persist
  end

end
