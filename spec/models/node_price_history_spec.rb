require 'rails_helper'

RSpec.describe NodePriceHistory, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:node_price_history) { FactoryBot.create(:node_price_history) }

  it { should belong_to(:node) }

  it 'is valid with valid attributes' do
    expect(node_price_history).to be_valid
  end
end