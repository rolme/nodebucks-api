require 'rails_helper'

RSpec.describe Reward, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:reward) { FactoryBot.create(:reward) }

  it { should belong_to(:node) }
  it { should have_many(:transactions).dependent(:destroy) }

  it 'is valid with valid attributes' do
    expect(reward).to be_valid
  end

  describe '#name' do
    it 'returns cached crypto name' do
      expect(reward.name).to eq reward.node.name
    end
  end

  describe '#symbol' do
    it 'returns cached crypto symbol' do
      expect(reward.symbol).to eq reward.node.symbol
    end
  end
end
