# Crypto.find_by(name: 'Dash').update_attribute(:ticker_url, 'https://api.coinmarketcap.com/v2/ticker/131/')
# Crypto.find_by(name: 'ZCoin').update_attribute(:ticker_url, 'https://api.coinmarketcap.com/v2/ticker/1414/')
# Crypto.find_by(name: 'Polis').update_attribute(:ticker_url, 'https://api.coinmarketcap.com/v2/ticker/2359/')
# Crypto.find_by(name: 'PIVX').update_attribute(:ticker_url, 'https://api.coinmarketcap.com/v2/ticker/1169/')
# Crypto.find_by(name: 'Stipend').update_attribute(:ticker_url, 'https://api.coinmarketcap.com/v2/ticker/2616/')


module NodeManager
  class Ticker
    attr_accessor :node

    def initialize(node)
      @node = node
    end

    def evaluate
      return if node.stake.blank?
      crypto_price = CryptoPrice.find_by(amount: 1, crypto_id: node.crypto.id).usdt.to_f
      node.node_prices.create(
        source: :system,
        value: node.stake * crypto_price
      )
    end
  end
end
