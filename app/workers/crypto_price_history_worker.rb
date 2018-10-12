class CryptoPriceHistoryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    Api::CoinMarketCap.new.save_coin_prices
  end
end
