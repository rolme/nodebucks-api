module NodeManager
  class Builder
    attr_accessor :node
    attr_reader :crypto, :error, :user

    def initialize(user, crypto, cost=nil)
      @crypto   = crypto
      @user     = user
      @node     = Node.find_by(user_id: user.id, crypto_id: crypto.id, status: 'reserved')
      @node   ||= Node.new(
        account_id: user.accounts.find { |a| a.crypto_id == crypto.id }&.id,
        user_id: user.id,
        crypto_id: crypto.id,
        cost: cost.present? ? cost : crypto.node_price,
        sell_price: crypto.node_sell_price,
        status: 'reserved',
        buy_priced_at: DateTime.current
      )
    end

    def latest_pricing
      np = NodeManager::Pricer.new(persist: true)
      np.evaluate(@crypto)
      @crypto.reload
    end

    def save(timestamp=DateTime.current)
      latest_pricing
      if node.id.present?
        node.reload
        node.update_attributes(
          cost: node.crypto.node_price,
          sell_price: node.crypto.node_sell_price,
          buy_priced_at: timestamp
        )
        return node
      end

      node.account ||= user.accounts.create(crypto_id: crypto.id)
      if node.save
        node
      else
        @error = @node.errors.full_messages.join(', ')
        false
      end
    end
  end
end
