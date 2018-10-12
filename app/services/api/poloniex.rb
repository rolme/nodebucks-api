module Api
  class Poloniex < Base
    BASE_URI    = "https://poloniex.com/public"
    DEBUG       = false
    EXCHANGE    = 'Poloniex'

    attr_reader :btc_usdt

    def initialize(type='sell')
      @type   = (type == 'sell') && "asks"
      @type ||= (type == 'buy') && "bids"

      response  = Typhoeus::Request.get("#{BASE_URI}?command=returnOrderBook&currencyPair=USDT_BTC&depth=1000", timeout: 3, verbose: DEBUG)
      data      = (response.body[@type]) ? parsed_response(response.body)[@type] : []
      orders    = to_orders(data)
      @btc_usdt =btc_order_price(orders, 1.0)
    end

    def orders(symbol)
      @path    = "#{BASE_URI}?command=returnOrderBook&currencyPair=BTC_#{symbol.upcase}&depth=1000"
      response = Typhoeus::Request.get(@path, timeout: 3, verbose: DEBUG)
      data     = parsed_response(response.body)
      return [] unless data[@type].present?

      data = parsed_response(response.body)[@type]
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
          price: order[0].to_f,
          volume: order[1].to_f
        }
      end.sort_by { |order| order [:price] }
    end

  end
end
