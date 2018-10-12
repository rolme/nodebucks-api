class NodeOfflineNotifierWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(*args)
    Node.all.each do |node|
      if node.status == 'offline' && !node.deleted?
        SupportMailerService.send_node_offline_notification(node)
      elsif node.status == 'online' && node.ip.present? && node.server_down?
        SupportMailerService.send_node_failed_ping_notification(node)
      end
    end
  end
end
