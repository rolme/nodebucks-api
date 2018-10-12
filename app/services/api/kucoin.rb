module Api
  class Kucoin < Base
    BASE_URI    = "https://api.kucoin.com"
    DEBUG       = false
    EXCHANGE    = 'Kucoin'

    if Rails.env == 'production'
      API_KEY    = ENV['KUCOIN_API_KEY']
      API_SECRET = ENV['KUCOIN_API_SECRET']
    else
      API_KEY    = Rails.application.credentials.kucoin[:api_key]
      API_SECRET = Rails.application.credentials.kucoin[:secret]
    end

    attr_reader :btc_usdt

    def initialize(type="sell")
      @type     = type
      nonce     = Api::Base.nonce
      params    = "limit=1000&symbol=BTC-USDT"
      end_point = "/v1/open/orders-#{@type}"
      sig       = signature(API_SECRET, end_point, nonce, params)

      response = Typhoeus::Request.get("#{BASE_URI}#{end_point}?#{params}", headers: {
        'Content-Type' => 'application/json',
        'KC-API-KEY' => API_KEY,
        'KC-API-NONCE' => nonce,
        'KC-API-SIGNATURE' => sig
      }, timeout: 3, verbose: DEBUG)
      orders    = (response.body['success']) ? to_orders(parsed_response(response.body)['data']) : []
      @btc_usdt =btc_order_price(orders, 1.0)
    end

    def orders(symbol)
      nonce     = Api::Kucoin.nonce
      params    = "limit=1000&symbol=#{symbol.upcase}-BTC"
      end_point = "/v1/open/orders-#{@type}"
      response = Typhoeus::Request.get("#{BASE_URI}#{end_point}?#{params}", headers: {
        'Content-Type' => 'application/json',
        'KC-API-KEY' => API_KEY,
        'KC-API-NONCE' => nonce,
        'KC-API-SIGNATURE' => signature(end_point, nonce, params)
      }, timeout: 3, verbose: DEBUG)

      data = parsed_response(response.body)
      return [] unless data["success"]

      orders = data['data']
      to_orders(data['data'])
    end

    def btc_to_usdt(btc)
      btc * btc_usdt
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

    def signature(secret, end_point, nonce, params=nil)
      encoded = Base64.strict_encode64("#{end_point}/#{nonce}/#{params}")
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, encoded)
    end

  end
end
