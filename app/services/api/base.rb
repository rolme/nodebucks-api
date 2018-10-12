module Api
  class Base

    def self.nonce
      DateTime.current.to_i
    end

    def btc_order_price(orders, limit)
      return 0.0 if orders.count == 0
      total  = 0
      i      = 0
      value  = 0

      while (orders.count > i && limit > total) do
        remaining_units = limit - total
        volume = (remaining_units <= orders[i][:volume]) ? remaining_units : orders[i][:volume]
        total += volume
        value += orders[i][:price] * volume
        i += 1
      end
      return value if liquid?(orders, limit)
      value + orders.last[:price] * (limit - total)
    end

    def liquid?(orders, limit)
      return false if orders.empty?
      orders.map{ |order| order[:volume] }.reduce(&:+) > limit.to_f
    end

  protected

    def parsed_response(response)
      begin
        JSON.parse(response)
      rescue JSON::ParserError => e
        { error: e.to_s }
      end
    end

  end
end
