module Api
  class Bittrex < Base
    BASE_URI    = "https://bittrex.com/api"
    DEBUG       = false
    EXCHANGE    = 'Bittrex'

    attr_reader :btc_usdt

    def initialize(type='sell')
      @type     = type
      response  = Typhoeus::Request.get("#{BASE_URI}/v1.1/public/getorderbook?market=USDT-BTC&type=#{@type}", timeout: 3, verbose: DEBUG)
      data      = (response.body['success']) ? parsed_response(response.body)['result'] : []
      orders    = to_orders(data)
      @btc_usdt =btc_order_price(orders, 1.0)
    end

    def orders(symbol)
      @path    = "#{BASE_URI}/v1.1/public/getorderbook?market=BTC-#{symbol.upcase}&type=#{@type}"
      response = Typhoeus::Request.get(@path, timeout: 3, verbose: DEBUG)
      data     = parsed_response(response.body)
      return [] unless data["success"]

      data = parsed_response(response.body)['result']
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
          price: order['Rate'].to_f,
          volume: order['Quantity'].to_f
        }
      end.sort_by { |order| order [:price] }
    end

  end
end
