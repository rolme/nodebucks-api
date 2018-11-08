class NodeSellPriceHistory < ApplicationRecord
  belongs_to :crypto

  scope :by_days, ->(n) { where(created_at: n.days.ago..DateTime.current) }

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
    return [] if prices.blank?

    prices.map do |key,value|
      avg_value = Utils.average(value.collect { |v| v['value']})
      {
        key => {
          value: avg_value.round(5)
        }
      }
    end
  end
end
