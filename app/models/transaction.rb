class Transaction < ApplicationRecord
  include Sluggable

  belongs_to :account, optional: true
  belongs_to :reward, optional: true
  belongs_to :withdrawal, optional: true

  validate :reference_exist, on: :create

  scope :pending, -> { where(status: :pending) }
  scope :processed, -> { where(status: :processed) }
  scope :cancelled, -> { where(status: :cancelled) }

  before_create :cache_values

  def name
    cached_crypto_name
  end

  def symbol
    cached_crypto_symbol
  end

  def cancel!
    update_attributes(cancelled_at: DateTime.current, status: 'cancelled')
  end

  def process!
    update_attributes(status: 'processed')
  end

  def undo!
    update_attributes(status: 'pending')
  end

  def cache_values(persist=false)
    if reward_id.present?
      reward = Reward.find_by(id: reward_id)
      self.cached_crypto_name = reward&.name
      self.cached_crypto_symbol = reward&.symbol
    end

    save! if persist
  end

  def reverse!
    case txn_type
    when 'transfer'; cancel!
    when 'deposit'; reverse_deposit!
    when 'withdraw'; reverse_withdraw!
    end
  end

private
  def reference_exist
    if account_id.nil? && reward_id.nil? && withdrawal_id.nil?
      errors.add(:account_id, "Reference must exist for an account, reward, or withdrawal.")
    end
  end


  def reverse_deposit!
    Transaction.transaction do
      txn = account.transactions.create(
        amount: amount,
        withdrawal_id: withdrawal_id,
        txn_type: 'withdraw',
        notes: "Reverse txn #{id}: #{notes}"
      )
      account.update_attribute(:balance, account.balance - amount)
      txn.process!
    end
  end

  def reverse_withdraw!
    Transaction.transaction do
      txn = nil
      if notes.include?("Affiliate reward withdrawal") && !!withdrawal_id
        txn = withdrawal.transactions.create(
          amount: amount,
          withdrawal_id: withdrawal_id,
          txn_type: 'deposit',
          notes: "Reverse txn #{id}: #{notes}"
        )
        withdrawal.user.update_attribute(:affiliate_balance, withdrawal.user.affiliate_balance + amount)
      else
        txn = account.transactions.create(
          amount: amount,
          withdrawal_id: withdrawal_id,
          txn_type: 'deposit',
          notes: "Reverse txn #{id}: #{notes}"
        )
        account.update_attribute(:balance, account.balance + amount)
      end
      txn.process!
    end
  end


end
