class NodeDailyTicker

  def self.run
    self.scrape
  end

  def self.scrape(a_node=nil)
    nodes = (a_node.present?) ? [a_node] : Node.online

    nodes.each do |node|
      ticker = NodeManager::Ticker.new(node)
      ticker.evaluate
    end
  end
end
