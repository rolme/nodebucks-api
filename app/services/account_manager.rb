class AccountManager
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def balance
    balances = {}
    pricer = NodeManager::Pricer.new(type: 'buy')
    Crypto.active.each do |crypto|
      coins  = coin_balance(crypto)
      prices = pricer.withdrawal(crypto, coins)
      blances[crypto.symbol] = coins
      blances['btc'] = (blances['btc'].present?) ? blances['btc'] + prices[:btc] : prices[:btc]
      blances['usd'] = (blances['usd'].present?) ? blances['usd'] + prices[:usd] : prices[:usd]
    end
    balances
  end

protected

  def coin_balance(crypto)
    nodes = user.nodes.select { |node| node.crypto_id == crypto.id }
    nodes.blank? ? 0.0 : nodes.map { |nodes| nodes.balance }.reduce(&:+)
  end
end
