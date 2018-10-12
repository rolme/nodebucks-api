class NodeRewarderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    NodeRewarder.run
  end
end
