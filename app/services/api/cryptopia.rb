module Api
  class Cryptopia < Base
    BASE_URI    = "https://www.cryptopia.co.nz/api"
    DEBUG       = false
    EXCHANGE    = 'Cryptopia'

    attr_reader :btc_usdt

    def initialize(type="sell")
      @type     = type.capitalize
      response  = Typhoeus::Request.get("#{BASE_URI}/GetMarketOrders/BTC_USDT", timeout: 3, verbose: DEBUG)
      data      = (response.body['Success']) ? parsed_response(response.body)['Data'] : []
      orders    = (!!data && !!data[@type]) ? to_orders(data[@type]) : []
      @btc_usdt =btc_order_price(orders, 1.0)
    end

    def orders(symbol)
      @path    = "#{BASE_URI}/GetMarketOrders/#{symbol.upcase}_BTC?orderCount=1000"
      response = Typhoeus::Request.get(@path, timeout: 3, verbose: DEBUG)
      data     = parsed_response(response.body)
      return [] unless data["Success"]
      return [] if parsed_response(response.body)['Data'].nil?

      data = parsed_response(response.body)['Data'][@type]
      to_orders(data)
    end

    def btc_to_usdt(btc)
      btc * btc_usdt
    end

  private

    # Returns Array of Hash [{ price: float, volume: float }, ...]
    def to_orders(data)
      id = 0
      data.map do |order|
        {
          id: id+=1,
          btc_ustd: @btc_usdt,
          exchange: EXCHANGE,
          price: order['Price']&.to_f,
          volume: order['Volume']&.to_f
        }
      end.sort_by { |order| order [:price] }
    end

  end
end
