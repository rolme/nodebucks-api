class CryptoPriceHistory < ApplicationRecord
  belongs_to :crypto

  scope :by_days, ->(n) { where("created_at >= ? AND created_at <= ?", Time.zone.now - n.days, Time.zone.now ) }

  scope :by_timeframe, ->(timeframe) {
    case timeframe
    when 'daily'
      group_by {|t| t.created_at.beginning_of_day }
    when 'hourly'
      group_by {|t| t.created_at.beginning_of_hour }
    when 'monthly'
      group_by {|t| t.created_at.beginning_of_month }
    end
  }

  def self.averages(prices)
    prices.map do |key,value|
      avg_circulating_supply = Utils.average(value.collect { |v| v['circulating_supply']})
      avg_total_supply = Utils.average(value.collect { |v| v['total_supply']})
      avg_max_supply = Utils.average(value.collect { |v| v['max_supply']})
      avg_price_usd = Utils.average(value.collect { |v| v['price_usd']})
      avg_volume_24h = Utils.average(value.collect { |v| v['volume_24h']})
      avg_market_cap = Utils.average(value.collect { |v| v['market_cap']})
      {
        [key] => {
          circulating_supply: avg_circulating_supply.round(5),
          total_supply: avg_total_supply.round(5),
          max_supply: avg_max_supply.round(5),
          price_usd: avg_price_usd.round(5),
          volume_24h: avg_volume_24h.round(5),
          market_cap: avg_market_cap.round(5),
        }
      }
    end
  end
end
