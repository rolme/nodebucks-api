class CryptoScraperWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    CryptoScraper.run
  end
end
