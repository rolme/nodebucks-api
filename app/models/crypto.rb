class Crypto < ApplicationRecord
  include Sluggable

  YEARLY     = 365
  MONTHLY    = 30
  WEEKLY     = 7
  PERCENTAGE = false
  VALUE      = true

  PURCHASE_STATUS_AVAILABLE   = "Buy Node"
  PURCHASE_STATUS_CONTACT     = "Contact Us"
  PURCHASE_STATUS_UNAVAILABLE = "Unavailable"

  PURCHASABLE_STATUSES = [
    PURCHASE_STATUS_AVAILABLE,
    PURCHASE_STATUS_CONTACT,
    PURCHASE_STATUS_UNAVAILABLE
  ]

  has_many :nodes
  has_many :crypto_price_histories
  has_many :sell_prices, class_name: "NodeSellPriceHistory", dependent: :destroy

  scope :active, -> { where(status: 'active') }
  scope :available, -> { where(exchanges_available: true) }

  def purchasable?
    User.system.current_float > node_price
  end

  # This is run on :before_create as part of Sluggable
  def generate_slug(force=false)
    self.slug = name.parameterize if slug.nil? || force
  end

  def withdrawable?
    status != 'inactive' &&
    purchasable_status != 'Unavailable'
  end

  def yearly_roi
    @_yearly_roi ||= {
      days: YEARLY,
      percentage: roi(YEARLY, PERCENTAGE),
      value: roi(YEARLY, VALUE)
    }
  end

  def monthly_roi
    @_monthly_roi ||= {
      days: MONTHLY,
      percentage:  roi(MONTHLY, PERCENTAGE),
      value: roi(MONTHLY, VALUE)
    }
  end

  def weekly_roi
    @_weekly_roi ||= {
      days: WEEKLY,
      percentage: roi(WEEKLY, PERCENTAGE),
      value: roi(WEEKLY, VALUE)
    }
  end

  def node_sell_price
    sellable_price - (sellable_price * (percentage_conversion_fee * 2))
  end

private

  def roi(days, format_type=VALUE)
    @__usdt_price ||= CryptoPrice.find_by(crypto_id: id, amount: 10, price_type: 'buy').usdt
    value = daily_reward * days.to_f * @__usdt_price
    (format_type) ? value : value/node_price
  end

end
