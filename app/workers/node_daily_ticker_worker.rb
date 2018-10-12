class NodeDailyTickerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    NodeDailyTicker.run
  end
end
