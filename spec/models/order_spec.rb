require 'rails_helper'

RSpec.describe Order, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:order) { FactoryBot.create(:order) }

  it { should belong_to(:user) }
  it { should belong_to(:node) }

  it 'is valid with valid attributes' do
    expect(order).to be_valid
  end

  describe '.unpaid' do
    let(:unpaid_orders) { FactoryBot.create_list(:order, 4, status: :unpaid) }

    it 'returns unpaid orders' do
      expect(Order.unpaid).to eq unpaid_orders
    end
  end

  describe '.filter_by_node' do
    it 'returns order matching node slug' do
      expect(Order.filter_by_node(order.node.slug)).to eq [order]
    end
  end

  describe '.filter_by_user' do
    it 'returns order matching user slug' do
      expect(Order.filter_by_user(order.user.slug)).to eq [order] 
    end
  end

  describe '#paid!' do
    it 'updates order status to paid' do
      order.paid!
      expect(order.status).to eq 'paid'
    end
  end

  describe '#unpaid!' do
    it 'updates order status to unpaid' do
      order.unpaid!
      expect(order.status).to eq 'unpaid'
    end
  end

  describe '#canceled!' do
    it 'updates order status to canceled' do
      order.canceled!
      expect(order.status).to eq 'canceled'
    end
  end
end
