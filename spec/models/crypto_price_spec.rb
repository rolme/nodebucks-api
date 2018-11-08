require 'rails_helper'

RSpec.describe CryptoPrice, type: :model do
  let!(:crypto_price) { FactoryBot.create(:crypto_price) }

  it { should belong_to(:crypto) }

  it 'is valid with valid attributes' do
    expect(crypto_price).to be_valid
  end
end
