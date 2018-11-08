require 'rails_helper'

RSpec.describe CryptoPriceHistory, type: :model do
  let(:crypto_price_history) { FactoryBot.create(:crypto_price_history) }

  it { should belong_to(:crypto) }

  it 'is valid with valid attributes' do
    expect(crypto_price_history).to be_valid
  end

  describe '.by_days' do
    it 'returns histories from n days ago' do
      3.times { |n| FactoryBot.create(:crypto_price_history, created_at: n.days.ago) }

      expect(CryptoPriceHistory.by_days(2).size).to eq 2
    end
  end

  describe '.by_timeframe' do
    context 'when timeframe is daily' do
      it 'returns histories grouped by days' do
        3.times { |n| FactoryBot.create(:crypto_price_history, created_at: n.days.ago) }

        expect(CryptoPriceHistory.by_timeframe('daily').size).to eq 3
      end
    end

    context 'when timeframe is hourly' do
      it 'returns histories grouped by hours' do
        4.times { |n| FactoryBot.create(:crypto_price_history, created_at: n.hours.ago) }

        expect(CryptoPriceHistory.by_timeframe('hourly').size).to eq 4
      end
    end

    context 'when timeframe is monthly' do
      it 'returns histories grouped by months' do
        3.times { |n| FactoryBot.create(:crypto_price_history, created_at: n.months.ago) }

        expect(CryptoPriceHistory.by_timeframe('monthly').size).to eq 3
      end
    end
  end

  describe '.averages' do
    it 'returns history averages' do
      expect(CryptoPriceHistory.averages({
        '2018-10-29' => [
          {
            'circulating_supply' => 1000,
            'total_supply' => 1500,
            'max_supply' => 2000,
            'price_usd' => 10,
            'volume_24h' => 200,
            'market_cap' => 2000,
          },
          {
            'circulating_supply' => 3000,
            'total_supply' => 4500,
            'max_supply' => 3000,
            'price_usd' => 20,
            'volume_24h' => 300,
            'market_cap' => 3000,
          },
        ]
      })).to eq ([{
        ['2018-10-29'] => {
          :circulating_supply => 2000,
          :total_supply => 3000,
          :max_supply => 2500,
          :price_usd => 15,
          :volume_24h => 250,
          :market_cap => 2500,
        }
      }])
    end
  end
end
