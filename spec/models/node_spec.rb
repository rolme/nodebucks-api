require 'rails_helper'

RSpec.describe Node, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:node) { FactoryBot.create(:node_with_rewards) }

  it { should belong_to(:account) }
  it { should belong_to(:crypto) }
  it { should belong_to(:creator) }
  it { should belong_to(:user) }
  it { should have_many(:orders) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:node_prices).dependent(:destroy) }
  it { should have_many(:rewards).dependent(:destroy) }

  it { should delegate_method(:explorer_url).to(:crypto) }
  it { should delegate_method(:percentage_conversion_fee).to(:crypto) }
  it { should delegate_method(:percentage_hosting_fee).to(:crypto) }
  it { should delegate_method(:price).to(:crypto) }
  it { should delegate_method(:stake).to(:crypto) }
  it { should delegate_method(:ticker_url).to(:crypto) }

  it { should validate_presence_of :cost }
  it { should validate_uniqueness_of(:ip).scoped_to(:crypto_id) }
  it { should validate_uniqueness_of(:wallet).scoped_to(:crypto_id) }

  it 'is valid with valid attributes' do
    expect(node).to be_valid
  end

  describe 'scope methods' do
    let!(:deleted_nodes) { FactoryBot.create_list(:node, 2, deleted_at: Time.now) }

    describe '.offline' do
      let(:offline_nodes) { FactoryBot.create_list(:node, 8, status: :offline) }
      
      it 'returns offline nodes' do
        expect(Node.offline).to eq offline_nodes
      end
    end

    describe '.online' do
      let(:online_nodes) { FactoryBot.create_list(:node, 6, status: :online) }
      
      it 'returns online nodes' do
        expect(Node.online).to eq online_nodes
      end
    end

    describe '.reserved' do
      let(:reserved_nodes) { FactoryBot.create_list(:node, 4, status: :reserved) }
      
      it 'returns reserved nodes' do
        expect(Node.reserved).to eq reserved_nodes
      end
    end

    describe '.unreserved' do
      let(:unreserved_nodes) { FactoryBot.create_list(:node, 3, status: :sold) }
      
      it 'returns unreserved nodes' do
        expect(Node.unreserved).to eq unreserved_nodes
      end
    end

    describe '.unsold' do
      let(:unsold_nodes) { FactoryBot.create_list(:node, 4, status: :reserved) }
      
      it 'returns unsold nodes' do
        expect(Node.unsold).to eq unsold_nodes
      end
    end

    describe '.sold' do
      let(:sold_nodes) { FactoryBot.create_list(:node, 2, status: :sold) }
      
      it 'returns sold nodes' do
        expect(Node.sold).to eq sold_nodes
      end
    end

    describe '._new' do
      let(:new_nodes) { FactoryBot.create_list(:node, 1, status: :new) }
      
      it 'returns new nodes' do
        expect(Node._new).to eq new_nodes
      end
    end

    describe '.down' do
      let(:down_nodes) { FactoryBot.create_list(:node, 2, status: :down) }
      
      it 'returns down nodes' do
        expect(Node.down).to eq down_nodes
      end
    end
  end

  describe 'instance methods' do
    describe '#total_fees' do
      it 'returns total rewards fees amount' do
        expect(node.total_fees).to eq 8
      end
    end

    describe '#buy_profit' do
      let(:node) { FactoryBot.build_stubbed(:node, cost: 20000, nb_buy_amount: 18000) }
      
      it 'returns buy profit' do
        expect(node.buy_profit).to eq 2000
      end
    end

    describe '#sell_profit' do
      context 'when sell price is present' do
        let(:node) { FactoryBot.build_stubbed(:node, sell_price: 21000, nb_sell_amount: 18000) }
        
        it 'returns sell profit' do
          expect(node.sell_profit).to eq 3000
        end
      end

      context 'when sell price is not present' do
        it 'returns 0' do
          expect(node.sell_profit).to eq 0
        end
      end
    end

    describe '#name' do
      it 'returns cached crypto name' do
        expect(node.name).to eq node.crypto.name
      end
    end

    describe '#symbol' do
      it 'returns cached crypto symbol' do
        expect(node.symbol).to eq node.crypto.symbol
      end
    end

    describe '#ready?' do
      context 'when wallet and ip are present' do
        let(:node) { FactoryBot.build_stubbed(:node, wallet: 'GZGDNpbFRUuz5fsSqnT6zwTcrJ9qB2rw2a') }
        
        it 'returns true' do
          expect(node.ready?).to be true
        end
      end

      context 'when wallet is not present' do
        it 'returns false' do
          expect(node.ready?).to be false
        end
      end
    end

    describe '#value' do
      let(:crypto) { FactoryBot.build_stubbed(:crypto, sellable_price: 10000, percentage_conversion_fee: 0.03) }
      let(:node) { FactoryBot.build_stubbed(:node, crypto: crypto ) }
      
      it 'returns node value' do
        expect(node.value).to eq 9400
      end
    end

    describe '#uptime' do
      context 'when online at is blank' do
        let(:node) { FactoryBot.build_stubbed(:node, status: :online, online_at: nil ) }

        it 'returns 0' do
          expect(node.uptime).to eq 0
        end
      end

      context 'when online at is present' do
        let(:node) { FactoryBot.build_stubbed(:node, status: :online, online_at: 2.days.ago) }

        it 'returns 2 days' do
          expect(node.uptime).to eq 2.days
        end
      end
    end

    describe '#wallet_url' do
      context 'when crypto symbol is pivx' do
        let(:crypto) { FactoryBot.build_stubbed(:crypto, explorer_url: 'https://chainz.cryptoid.info/pivx/address.dws?') }
        let(:node) { FactoryBot.build_stubbed(:node, crypto: crypto, cached_crypto_symbol: :pivx, wallet: 'PFyM75zUNrVUcK5XDcaT4moRuKTsnDqWaZ' ) }

        it 'returns wallet url' do
          expect(node.wallet_url).to eq 'https://chainz.cryptoid.info/pivx/address.dws?PFyM75zUNrVUcK5XDcaT4moRuKTsnDqWaZ.htm'
        end
      end

      context 'when crypto symbol is not pivx' do
        let(:crypto) { FactoryBot.build_stubbed(:crypto, explorer_url: 'http://explorer.stipend.me/address/') }
        let(:node) { FactoryBot.build_stubbed(:node, crypto: crypto, wallet: 'PFyM75zUNrVUcK5XDcaT4moRuKTsnDqWaZ' ) }

        it 'returns wallet url' do
          expect(node.wallet_url).to eq 'http://explorer.stipend.me/address/PFyM75zUNrVUcK5XDcaT4moRuKTsnDqWaZ'
        end
      end
    end

    describe '#reward_total' do
      let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: node.crypto, amount: 25, btc: 0.2, usdt: 120, price_type: :sell) }

      it 'returns total reward' do
        expect(node.reward_total).to eq 4512
      end
    end

    describe '#week_reward' do
      let(:node_with_weekly_rewards) { FactoryBot.create(:node_with_weekly_rewards) }
      let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: node_with_weekly_rewards.crypto, amount: 10, btc: 0.2, usdt: 120, price_type: :sell) }

      it 'returns total reward from last 7 days' do
        expect(node_with_weekly_rewards.week_reward).to eq 2256
      end
    end

    describe '#month_reward' do
      let(:node_with_monthly_rewards) { FactoryBot.create(:node_with_monthly_rewards) }
      let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: node_with_monthly_rewards.crypto, amount: 50, btc: 0.2, usdt: 120, price_type: :sell) }

      it 'returns total reward from last 7 days' do
        expect(node_with_monthly_rewards.month_reward).to eq 6768
      end
    end

    describe '#quarter_reward' do
      let(:node_with_querterly_rewards) { FactoryBot.create(:node_with_querterly_rewards) }
      let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: node_with_querterly_rewards.crypto, amount: 50, btc: 0.2, usdt: 120, price_type: :sell) }

      it 'returns total reward from last 7 days' do
        expect(node_with_querterly_rewards.quarter_reward).to eq 10152
      end
    end

    describe '#year_reward' do
      let(:node_with_yearly_rewards) { FactoryBot.create(:node_with_yearly_rewards) }
      let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: node_with_yearly_rewards.crypto, amount: 50, btc: 0.2, usdt: 120, price_type: :sell) }

      it 'returns total reward from last 7 days' do
        expect(node_with_yearly_rewards.year_reward).to eq 6768
      end
    end

    describe '#cost_to_cents' do
      let(:node) { FactoryBot.create(:node_with_rewards, cost: 20000) }

      it 'returns node cost in cents' do
        expect(node.cost_to_cents).to eq 2000000
      end
    end

    describe '#sell!' do
      it 'updates node status to sold' do
        node.sell!
        expect(node.status).to eq 'sold'
      end
    end

    describe '#duplicated_ip?' do
      context 'when there is no more than 1 node with same ip and crypto' do
        it 'returns false' do
          expect(node.duplicated_ip?).to be false
        end
      end
    end

    describe '#duplicated_wallet?' do
      context 'when there is no more than 1 node with same wallet and crypto' do
        it 'returns false' do
          expect(node.duplicated_wallet?).to be false
        end
      end
    end

    describe '#server_down?' do
      context 'with bad ip adress' do
        let(:node) { FactoryBot.create(:node_with_rewards, ip: '165.227.1.20x') }

        it 'returns true' do
          expect(node.server_down?).to be true
        end
      end
    end
  end
end
