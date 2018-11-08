require 'rails_helper'

RSpec.describe Announcement, type: :model do
  let(:announcement) { FactoryBot.create(:announcement) }

  it 'is valid with valid attributes' do
    expect(announcement).to be_valid
  end
end
