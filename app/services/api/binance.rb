module Api
  class Binance < Base
    BASE_URI    = "https://api.binance.com"
    DEBUG       = false
    EXCHANGE    = 'Binance'

    if Rails.env == 'production'
      API_KEY    = ENV['BINANCE_API_KEY']
      API_SECRET = ENV['BINANCE_API_SECRET']
    else
      API_KEY    = Rails.application.credentials.binance[:api_key]
      API_SECRET = Rails.application.credentials.binance[:secret]
    end

    attr_reader :btc_usdt

    def initialize(type='sell')
      @type   = (type == 'sell') && "asks"
      @type ||= (type == 'buy') && "bids"

      nonce     = Api::Base.nonce
      params    = "limit=1000&symbol=BTCUSDT"
      end_point = "/api/v1/depth"

      response = Typhoeus::Request.get("#{BASE_URI}#{end_point}?#{params}", headers: {
        'X-MBX-APIKEY' => API_KEY
      }, timeout: 3, verbose: DEBUG)
      asks   = response.body[@type].present? ? parsed_response(response.body)[@type] : []
      orders = to_orders(asks)

      @btc_usdt = btc_order_price(orders, 1.0)
    end

    def orders(symbol)
      nonce     = Api::Base.nonce
      params    = "limit=1000&symbol=#{symbol.upcase}BTC"
      end_point = "/api/v1/depth"

      response = Typhoeus::Request.get("#{BASE_URI}#{end_point}?#{params}", headers: {
        'X-MBX-APIKEY' => API_KEY
      }, timeout: 3, verbose: DEBUG)

      data = parsed_response(response.body)
      return [] unless data[@type]

      orders = data[@type]
      to_orders(data[@type])
    end

    def btc_to_usdt(btc)
      btc * btc_usdt
    end

    def available?(symbol)
      response = Typhoeus::Request.get("#{BASE_URI}/api/v1/depth?limit=1000&symbol=#{symbol.upcase}BTC", headers: {
        'X-MBX-APIKEY' => API_KEY
      }, timeout: 3, verbose: DEBUG)

      response.code == 200
    end

  private

    # Returns Array of Hash [{ price: float, volume: float }, ...]
    def to_orders(orders)
      id = 0
      orders.map do |order|
        {
          id: id += 1,
          btc_usdt: @btc_usdt,
          exchange: EXCHANGE,
          price: order[0].to_f,
          volume: order[1].to_f
        }
      end
    end

    def signature(secret, nonce, params=nil)
      encoded = Base64.strict_encode64("#{params}?timestamp=#{nonce}")
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, encoded)
    end

  end
end
