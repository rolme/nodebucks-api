module NodeManager
  class Operator
    attr_reader :error, :node, :order

    def initialize(node)
      @node = node
    end

    def reward(timestamp, amount, txhash)
      # return false unless (node.crypto.block_reward - amount).abs <= 1.0

      fee = amount * node.percentage_hosting_fee
      total_amount = amount - fee
      usd_value    = total_amount * node.crypto_price
      reward = Reward.create(
        amount: amount,
        fee: fee,
        node_id: node.id,
        timestamp: timestamp,
        total_amount: total_amount,
        txhash: txhash,
        usd_value: usd_value,
        node_reward_setting: node.reward_setting
      )

      create_reward_event(reward)
      tm = TransactionManager.new(node.account)
      tm.deposit_reward(reward)
      NodeOwnerMailer.reward(reward).deliver_later
    end

    def online(timestamp=DateTime.current)
      return false if node.status == 'online'
      node.update_attributes(status: 'online', online_at: timestamp)
      node.events.create(event_type: 'ops', timestamp: timestamp, description: "Server online")

      NodeOwnerMailer.online(node).deliver_later
    end

    def disburse(timestamp=DateTime.current)
      return false if node.status != 'sold'
      node.orders.find_by(order_type: 'sold', status: 'unpaid')&.paid!
      node.update_attributes(status: 'disbursed', disbursed_at: timestamp)
      node.events.create(event_type: 'ops', timestamp: timestamp, description: "Server stopped and funds disbursed")
    end

    def undisburse(timestamp=DateTime.current)
      return false if node.status != 'disbursed'
      node.orders.find_by(order_type: 'sold', status: 'paid')&.unpaid!
      node.update_attributes(status: 'sold')
      node.events.create(event_type: 'ops', timestamp: timestamp, description: "Undo fund disbursement")
    end

    def offline(timestamp=DateTime.current)
      return false if node.status != 'online'
      node.update_attribute(:status, 'offline')
      node.events.create(event_type: 'ops', timestamp: timestamp, description: "Server offline for maintenance")
    end

    def purchase(timestamp, paypal_json, payment_method='paypal')
      return false if node.status != 'reserved' || !within_timeframe?(node.buy_priced_at)

      node.update_attribute(:status, 'new')
      node.node_prices.create(source: 'system', value: node.cost)
      @order = Order.create(
        node_id: node.id,
        user_id: node.user_id,
        currency: 'usd',
        amount: node.cost,
        status: 'unpaid',
        order_type: 'buy',
        payment_method: payment_method,
        paypal_response: paypal_json,
        description: "#{node.user.email} purchased #{node.crypto.name} masternode for $#{node.cost}."
      )
      node.events.create(event_type: 'ops', timestamp: timestamp, description: "Server purchased")

      # Get latest prices
      pricer = NodeManager::Pricer.new({persist: true})
      pricer.evaluate(node.crypto)
      # TODO: Do we need to track setup fee here?
    end

    def reserve_sell_price(timestamp=DateTime.current)
      return false if node.status == 'sold'
      np = NodeManager::Pricer.new(persist: true, type: 'buy')
      np.evaluate(node.crypto)
      node.reload
      node.update_attributes(sell_price: node.crypto.node_sell_price, sell_priced_at: DateTime.current)
    end

    def sell(payment_method, target, timestamp=DateTime.current)
      return false if node.status == 'sold' || !within_timeframe?(node.sell_priced_at)

      node.update_attributes(status: 'sold', sold_at: timestamp)
      @order = Order.create(
        node_id: node.id,
        user_id: node.user_id,
        currency: 'usd',
        amount: node.cost,
        status: 'unpaid',
        order_type: 'sold',
        payment_method: payment_method,
        target: target,
        description: "#{node.user.email} sold #{node.crypto.name} masternode for $#{node.sell_price}."
      )
      node.events.create(event_type: 'ops', timestamp: timestamp, description: "Server sold")
    end

  protected

     def within_timeframe?(datetime)
       return false if datetime.blank?
       DateTime.current < (datetime + Node::TIME_LIMIT)
     end

     def create_reward_event(reward)
       node.events.create(
         event_type: 'reward',
         timestamp: reward.timestamp,
         value: reward.total_amount,
         description: "Reward: #{reward.amount.round(5)} #{node.symbol} (-#{reward.fee.round(5)} fee)"
       )
     end
  end
end
