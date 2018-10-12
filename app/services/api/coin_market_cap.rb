module Api
  class CoinMarketCap
    API_BASE = 'https://api.coinmarketcap.com/v2'

    def initialize
      @supported_coins = supported_coins
    end

    def save_coin_prices
      Crypto.all.each do |crypto|
        save_coin_price(coin_info(coin_id(crypto.symbol)), crypto)
      end
    end

    def coin_info(coin_id)
      Utils.parsed_response(Typhoeus::Request.get("#{API_BASE}/ticker/#{coin_id}/").body)['data']
    end

    def coin_id(symbol)
      @supported_coins.select { |c| c['symbol'].downcase === symbol }.first['id']
    end

    def supported_coins
      Utils.parsed_response(Typhoeus::Request.get("#{API_BASE}/listings/").body)['data']
    end

    def save_coin_price(info, crypto)
      CryptoPriceHistory.create(
        crypto_id: crypto.id,
        circulating_supply: info['circulating_supply'],
        total_supply: info['total_supply'],
        max_supply: info['max_supply'],
        price_usd: info['quotes']['USD']['price'],
        volume_24h: info['quotes']['USD']['volume_24h'],
        market_cap: info['quotes']['USD']['market_cap'],
      )
    end
  end
end
