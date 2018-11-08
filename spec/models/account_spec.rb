require 'rails_helper'

RSpec.describe Account, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:account) { FactoryBot.create(:account) }

  it { should belong_to(:user) }
  it { should belong_to(:crypto) }
  it { should have_many(:nodes) }
  it { should have_many(:transactions) }

  it { should delegate_method(:slug).to(:crypto) }

  it 'is valid with valid attributes' do
    expect(account).to be_valid
  end

  describe '#has_nodes?' do
    context 'when there is nodes with statuses disbursed, sold or reserved' do
      let(:account_with_nodes) { FactoryBot.create(:account_with_nodes) }

      it 'returns true' do
        expect(account_with_nodes.has_nodes?).to be true
      end
    end

    context 'when there is no nodes' do
      it 'returns false' do
        expect(account.has_nodes?).to be false
      end
    end
  end
end
