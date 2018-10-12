module Metable
  extend ActiveSupport::Concern

  included do
    before_action :default_meta_tags
    helper_method :meta_tags
  end

  def default_meta_tags
    @title ||= 'NodeBucks - Build your Masternode and Collect Rewards'
    @description ||= 'Operate your very own masternode and collect rewards in exchange for the work your masternode performs on the blockchain, confirming and verifying transactions of cryptocurrencies.'
    @image ||= "https://nodebucks.com/assets/og_nodebucks.jpg"
    @url   ||= "https://nodebucks.com/"
  end
end
