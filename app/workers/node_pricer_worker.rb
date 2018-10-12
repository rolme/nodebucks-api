class NodePricerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    NodeManager::Pricer.run
  end
end
