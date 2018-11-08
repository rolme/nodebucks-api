class User < ApplicationRecord
  include Sluggable
  include SoftDeletable

  SYSTEM_ACCOUNT_ID = 1
  TOKEN_AGE         = 15.minutes

  mount_uploader :avatar, AvatarUploader

  belongs_to :upline_user, foreign_key: :upline_user_id, class_name: 'User', optional: true

  has_many :accounts, dependent: :destroy
  has_many :affiliates
  has_many :nodes, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :withdrawals, dependent: :destroy

  has_secure_password

  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :new_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, allow_blank: true
  validates :reset_token, uniqueness: true, allow_blank: true
  validates :affiliate_key, uniqueness: true

  before_create :generate_affiliate_key
  after_create :create_btc_account

  mount_uploader :verification_image, VerificationImageUploader

  scope :verifications_pending, -> { where(verification_status: :pending) }

  def self.system
    @@_system ||= User.unscoped.find_by(id: SYSTEM_ACCOUNT_ID, email: nil)
  end

  def node_wallet_withdrawals(crypto_id)
    nodes.select{ |n| n.crypto_id == crypto_id }.map do |node|
      {
        balance: node.balance,
        wallet: node.wallet,
        url: node.wallet_url
      }
    end
  end

  def full_name
    "#{first} #{last}"
  end

  def enable!
    update_attribute(:enabled, true)
  end

  def disable!
    update_attribute(:enabled, false)
  end

  def reset!
    self.reset_token = SecureRandom.urlsafe_base64
    self.reset_at = DateTime.current
    save
  end

  def change_password!(password, password_confirmation)
    delete_token
    self.password = password
    self.password_confirmation = password_confirmation
    save
  end

  def token_valid?
    return false if reset_token.blank? or reset_at.blank?
    (reset_at + TOKEN_AGE) > DateTime.current
  end

  def delete_token!
    delete_token
    save
  end

  def verify_email!
    return true if new_email.blank?

    # TODO: There might be a chance that a user creates a subscription before
    #       verifying email...
    subscription.update_attribute(:email, new_email) if subscription.email != self.new_email
    self.email = new_email
    self.new_email = nil
    save
  end

  def delete_token
    self.reset_token = nil
    self.reset_at = nil
  end

  # TODO: This should be a separate services UserWithdrawal?
  def pending_withdrawal_value(crypto_id)
    pending = withdrawals.select { |w| w.crypto_id == crypto_id && w.status == 'pending' }
    return 0.0 if pending.blank?

    pending.map { |w| w.amount.to_f }.reduce(&:+)
  end

  # TODO: This should be a separate services UserWithdrawal?
  def balances
    Crypto.available.active.sort_by(&:name).map do |crypto|
      account = accounts.find { |a| a.crypto_id == crypto.id }
      filtered_nodes = nodes.select{ |n| n.crypto_id == crypto.id && ['online', 'new'].include?(n.status) }
      if account.nil?
        {
          btc: 0.0,
          fee: crypto.percentage_conversion_fee,
          has_nodes: false,
          name: crypto.name,
          slug: crypto.slug,
          symbol: crypto.symbol,
          usd: 0.0,
          value: 0.0,
          wallet: nil,
          withdrawable: crypto.withdrawable?
        }
      else
        crypto_pricer = CryptoPricer.new(account.crypto)
        btc = crypto_pricer.to_btc(account.balance, 'sell')
        usd = crypto_pricer.to_usdt(account.balance, 'sell')
        {
          btc: btc,
          fee: crypto.percentage_conversion_fee,
          has_nodes: filtered_nodes.present?,
          name: account.name,
          slug: crypto.slug,
          symbol: account.symbol,
          usd: usd,
          value: account.balance,
          wallet: account.wallet,
          withdrawable: crypto.withdrawable?
        }
      end
    end
  end

  def btc_wallet
    @btc_wallet ||= accounts.find { |a| a.symbol.downcase == 'btc' }.wallet
  end

  def total_balance
    btc = 0.0
    usd = 0.0
    accounts.each do |account|
      next unless account.crypto.withdrawable? && account.crypto.exchanges_available

      crypto_pricer = CryptoPricer.new(account.crypto)
      btc += crypto_pricer.to_btc(account.balance, 'sell')
      usd += crypto_pricer.to_usdt(account.balance, 'sell')
    end
    usd += affiliate_balance
    btc += Utils.usd_to_btc(affiliate_balance) # TODO: Should this have a 3% conversion fee?
    { btc: btc, usd: usd }
  end

  def reserved_node
    @__reserved_node ||= nodes.find { |n| n.status == 'reserved' }
  end

  def create_btc_account
    account   = accounts.find{ |a| a.symbol.downcase == 'btc' }
    account ||= accounts.create(crypto_id: Crypto.find_by(symbol: ['btc', 'BTC']).id)
  end

  def set_upline(affiliate_key)
    return if affiliate_key.blank?

    referral_user = User.find_by(affiliate_key: affiliate_key)
    return if referral_user.blank?

    self.update_attribute(:upline_user_id, referral_user.id)
    referral_user.affiliates.create(affiliate_user_id: id, level: 1)
    referral_user.upline&.affiliates&.create(affiliate_user_id: id, level: 2)
    referral_user.upline(2)&.affiliates&.create(affiliate_user_id: id, level: 3)
  end

  def upline(level=1)
    return nil if upline_user.blank?
    return nil if (level > 3 || level < 1)

    case level
    when 1; upline_user
    when 2; upline_user.upline
    when 3; upline_user.upline(2)
    else nil
    end
  end

  def update_affiliates(tier1_slug)
    Affiliate.where(affiliate_user_id: id).delete_all
    set_upline(User.find_by(slug: tier1_slug).affiliate_key)
  end

  def remove_affiliates
    Affiliate.where(affiliate_user_id: id).delete_all
    update_attribute(:upline_user_id, nil)
  end

  def generate_token
    JsonWebToken.encode({
      admin: admin,
      address: address,
      avatar: avatar,
      city: city,
      confirmedAt: confirmed_at&.to_formatted_s(:db),
      country: country,
      createdAt: created_at.to_formatted_s(:db),
      email: email,
      enabled: enabled,
      enabled2FA: two_fa_secret.present?,
      first: first,
      fullName: full_name,
      last: last,
      newEmail: new_email,
      nickname: nickname,
      rewardNotificationOn: reward_notification_on,
      slug: slug,
      state: state,
      updatedAt: updated_at.to_formatted_s(:db),
      zipcode: zipcode,
      verified: verified_at,
      verificationStatus: verification_status,
      verificationImage: verification_image,
    })
  end

  private

  def generate_affiliate_key
    self.affiliate_key = SecureRandom.urlsafe_base64
    self.affiliate_key_created_at = DateTime.current
  end
end
