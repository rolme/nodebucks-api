require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:users) { FactoryBot.create_list(:user, 5) }
  let(:referrer) { FactoryBot.create(:user) }

  it 'is valid with affiliate key' do
    users.each do |user|
      expect(user.affiliate_key).not_to eq(nil)
    end
  end
end
