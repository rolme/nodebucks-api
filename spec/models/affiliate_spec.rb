require 'rails_helper'

RSpec.describe Affiliate, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:affiliate) { FactoryBot.create(:affiliate) }

  it { should belong_to(:user) }
  it { should belong_to(:affiliate_user) }

  it 'is valid with valid attributes' do
    expect(affiliate).to be_valid
  end
end
