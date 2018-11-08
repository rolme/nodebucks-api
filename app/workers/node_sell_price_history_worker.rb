class NodeSellPriceHistoryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    Crypto.all.each do |crypto|
      NodeSellPriceHistory.create(crypto: crypto, value: crypto.node_sell_price)
    end
  end
end
