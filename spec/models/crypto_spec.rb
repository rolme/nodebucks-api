require 'rails_helper'

RSpec.describe Crypto, type: :model do
  let(:crypto) { FactoryBot.create(:crypto) }

  it { should have_many(:nodes) }
  it { should have_many(:crypto_price_histories) }

  it 'is valid with valid attributes' do
    expect(crypto).to be_valid
  end

  describe '.active' do
    context 'when there is no active cryptos' do
      it 'retruns no cryptos' do
        expect(Crypto.active.size).to eq 0
      end
    end

    context 'when there is active cryptos' do
      let!(:active_cryptos) { FactoryBot.create_list(:crypto, 8, status: :active) }

      it 'retruns no cryptos' do
        expect(Crypto.active).to eq active_cryptos
      end
    end
  end

  describe '#withdrawable?' do
    context 'when status is inactive' do
      it 'returns false' do
        expect(crypto.withdrawable?).to be false
      end
    end

    context 'when status is active and purchasable_status is not Unavailable' do
      let(:withdrawable_crypto) { FactoryBot.create(:crypto, status: :active, purchasable_status: Crypto::PURCHASE_STATUS_AVAILABLE) }

      it 'returns false' do
        expect(withdrawable_crypto.withdrawable?).to be true
      end
    end
  end

  describe 'roi methods' do
    let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: crypto, amount: 10, price_type: :buy) }
    describe '#yearly_roi' do
      it 'returns yearly roi' do
        expect(crypto.yearly_roi).to include(:days, :percentage, :value)
      end
    end

    describe '#monthly_roi' do
      it 'returns monthly roi' do
        expect(crypto.monthly_roi).to include(:days, :percentage, :value)
      end
    end

    describe '#weekly_roi' do
      it 'returns weekly roi' do
        expect(crypto.weekly_roi).to include(:days, :percentage, :value)
      end
    end
  end
end
