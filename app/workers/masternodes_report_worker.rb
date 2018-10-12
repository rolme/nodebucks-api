class MasternodesReportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    MasternodesReportMailer.send_report.deliver_later
  end
end
