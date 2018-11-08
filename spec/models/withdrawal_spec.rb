require 'rails_helper'

RSpec.describe Withdrawal, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:withdrawal) { FactoryBot.create(:withdrawal) }

  it { should belong_to(:admin) }
  it { should belong_to(:user) }
  it { should have_many(:transactions).dependent(:destroy) }

  it 'is valid with valid attributes' do
    expect(withdrawal).to be_valid
  end

  describe '.pending' do
    let(:pending_withdrawals) { FactoryBot.create_list(:withdrawal, 4, status: :pending) }

    it 'returns pending withdrawals' do
      expect(Withdrawal.pending).to eq pending_withdrawals
    end
  end

  describe '#destination' do
    it 'returns expected string' do
      expect(withdrawal.destination).to eq 'Bitcoin'
    end
  end
end
