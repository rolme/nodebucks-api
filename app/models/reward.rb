class Reward < ApplicationRecord
  belongs_to :node
  has_many :transactions, dependent: :destroy

  before_create :cache_values

  def name
    cached_crypto_name
  end

  def symbol
    cached_crypto_symbol
  end

  def cache_values(persist=false)
    cached_node = node || Node.find(node_id)
    self.cached_crypto_name = cached_node&.name
    self.cached_crypto_symbol = cached_node&.symbol

    save! if persist
  end
end
