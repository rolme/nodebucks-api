require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:user) { FactoryBot.create(:user) }
  let(:users) { FactoryBot.create_list(:user, 5) }
  let(:referrer) { FactoryBot.create(:user) }

  it 'is valid with affiliate key' do
    users.each do |user|
      expect(user.affiliate_key).not_to eq(nil)
    end
  end

  describe '#full_name' do
    it 'returns user`s full name' do
      expect(user.full_name).to eq("#{user.first} #{user.last}")
    end
  end

  describe '#change_password!' do
    it 'sets reset token to nil and changes password' do
      expect(user.change_password!('password123', 'password123')).to eq(true)
      expect(user.reset_token).to eq(nil)
    end

    it 'fails to change password' do
      expect(user.change_password!('password123', 'password')).to eq(false)
    end
  end

  describe '#token_valid?' do
    it 'returns true if tokens exists' do
      user.reset!
      expect(user.token_valid?).to eq(true)
    end

    it 'returns false if token does not exist' do
      expect(user.token_valid?).to eq(false)
    end
  end

  describe '#verify_email!' do
    it 'returns false new email is blank' do
      expect(user.verify_email!).to eq(true)
    end
  end

  describe '#delete_token' do
    it 'sets reset token to nil' do
      expect(user.reset_token).to eq(nil)
    end
  end

  describe '#delete_token!' do
    it 'deletes reset token' do
      expect(user.reset_token).to eq(nil)
    end
  end

  describe '#reset!' do
    it 'resets token to new value' do
      old_token = user.reset_token
      user.reset!
      expect(user.reset_token).not_to eq(old_token)
    end
  end

  describe '#pending_withdrawal_value' do
    let(:user_with_withdrawals) { FactoryBot.create(:user_with_withdrawals) }
    it 'returns 0 if no there are no withdrawals pending' do
      expect(user.pending_withdrawal_value(1)).to eq(0.0)
    end
  end

  describe '#balances' do
    let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: crypto) }
    let!(:account) { FactoryBot.create(:account) }

    it 'returns list of names of active cryptos' do
      expect(user.balances.count).to be > 0
    end
  end

  describe '#btc_wallet' do
    let(:account) { FactoryBot.create(:account) }
    it 'returns bitcoin wallet if exists' do
      user.accounts.clear
      user.accounts << account
      user.save!
      expect(user.btc_wallet).not_to eq(nil)
    end
  end

  describe '#total_balance' do
    let(:crypto_price) { FactoryBot.create(:crypto_price, crypto: crypto) }
    it 'returns total balance' do
      #expect(user.total_balance).to be >= 0.0
    end
  end

  describe '#reserved_node' do
    let!(:reserved_nodes) { FactoryBot.create_list(:reserved_node, 5, user: user) }
    let!(:nodes) { FactoryBot.create_list(:node, 5, user: referrer) }

    it 'returns reserved node if exists' do
      expect(user.reserved_node).not_to eq(nil)
    end
  end

  describe '#create_btc_account' do
    it 'returns created btc account' do
      expect(user.create_btc_account).not_to eq(nil)
    end
  end

  describe '#set_upline' do
    context 'when affiliate key or referrer are blank' do
      it 'returns void' do
        expect(user.set_upline('')).to eq(nil)
      end
    end
  end
end
