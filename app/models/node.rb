class Node < ApplicationRecord
  include Sluggable
  include SoftDeletable

  TIME_LIMIT = 180.seconds

  WEEK    = 7.days
  MONTH   = 30.days
  QUARTER = 90.days
  YEAR    = 365.days

  REWARD_AUTO_NONE       = 0
  REWARD_AUTO_BUILD      = 10
  REWARD_AUTO_WITHDRAWAL = 20

  SELL_BITCOIN_WALLET    = 0
  SELL_STRIPE            = 10

  belongs_to :account
  belongs_to :crypto
  belongs_to :creator, foreign_key: :created_by_admin_id, class_name: 'User', optional: true
  belongs_to :user

  has_many :orders
  has_many :events, dependent: :destroy
  has_many :node_prices, class_name: "NodePriceHistory", dependent: :destroy
  has_many :rewards, dependent: :destroy


  delegate :explorer_url,
           :flat_setup_fee,
           :name,
           :percentage_conversion_fee,
           :percentage_hosting_fee,
           :price,
           :stake,
           :symbol,
           :ticker_url,
           to: :crypto

  delegate :price,
          to: :crypto,
          prefix: true

  validates :cost, presence: true

  validates_uniqueness_of :ip, scope: :crypto_id, allow_blank: true
  validates_uniqueness_of :wallet, scope: :crypto_id, allow_blank: true

  scope :offline,    -> { where(status: 'offline', deleted_at: nil) }
  scope :online,     -> { where(status: 'online', deleted_at: nil) }
  scope :reserved,   -> { where(status: 'reserved', deleted_at: nil) }
  scope :unreserved, -> { where.not(status: 'reserved').where(deleted_at: nil) }
  scope :unsold,     -> { where.not(status: 'sold').where(deleted_at: nil) }
  scope :sold,       -> { where(status: 'sold', deleted_at: nil) }
  scope :_new,       -> { where(status: 'new', deleted_at: nil) }
  scope :down,       -> { where(status: 'down', deleted_at: nil) }

  before_create :cache_values

  def total_fees
    rewards.map(&:fee).reduce(&:+)&.round(5)
  end

  def total_fees_collected
    return 0 if rewards.count == 0

    @_transactions ||= Transaction.where(reward_id: rewards.map(&:id))
    @_transactions.select{ |t| t.status == 'processed' && t.txn_type == 'transfer' }.map(&:amount).reduce(&:+)&.round(5)
  end

  def buy_profit
    return 0 if cost.blank?
    (cost - nb_buy_amount).floor(2)
  end

  def sell_profit
    return 0 if sell_price.blank?
    (sell_price - nb_sell_amount).floor(2)
  end

  def name
    cached_crypto_name
  end

  def symbol
    cached_crypto_symbol
  end

  def ready?
    wallet.present? && ip.present?
  end

  def value
    @_value ||= crypto.sellable_price - (crypto.sellable_price * (percentage_conversion_fee * 2))
  end

  def uptime
    return 0 if online_at.blank? || status != 'online' || deleted_at.present?
    DateTime.current.to_i - online_at.to_i
  end

  def wallet_url
    return "#{explorer_url}#{wallet}.htm" if symbol == 'pivx'
    "#{explorer_url}#{wallet}"
  end

  # TODO: More math needed here
  def reward_total
    return @__reward_total if @__reward_total.present?

     total = rewards.map(&:total_amount).reduce(&:+) || 0.0
     crypto_pricer = CryptoPricer.new(crypto)
     @__reward_total = crypto_pricer.to_usdt(total, 'sell')
  end

  def week_reward
    reward_timeframe(WEEK)
  end

  def month_reward
    reward_timeframe(MONTH)
  end

  def quarter_reward
    reward_timeframe(QUARTER)
  end

  def year_reward
    reward_timeframe(YEAR)
  end

  def cache_values(persist=false)
    crypto = Crypto.find(crypto_id)
    self.cached_crypto_name = crypto&.name
    self.cached_crypto_symbol = crypto&.symbol

    save! if persist
  end

  def cost_to_cents
    (cost.floor(2) * 100).to_i
  end

  def sell!
    self.status = 'sold'
    save!
  end

  def duplicated_ip?
    ip.present? ? Node.where(crypto_id: crypto.id, ip: ip).count > 1 : false
  end

  def duplicated_wallet?
    wallet.present? ? Node.where(crypto_id: crypto.id, wallet: wallet).count > 1 : false
  end

  def server_down?
    return true if ip.nil?
    !Net::Ping::External.new(ip).ping?
  end

private

  def reward_timeframe(timeframe)
    now   = DateTime.current
    range = ((now-timeframe)..now)
    # rewards.select{ |r| range.cover?(r.timestamp) }.map(&:usd_value).reduce(&:+) || 0.0

    total = rewards.select{ |r| range.cover?(r.timestamp) }.map(&:total_amount).reduce(&:+) || 0.0
    crypto_pricer = CryptoPricer.new(crypto)
    crypto_pricer.to_usdt(total, 'sell')
  end
end
