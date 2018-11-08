require 'rails_helper'

RSpec.describe Event, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:event) { FactoryBot.create(:event) }

  it { should belong_to(:node) }

  it 'is valid with valid attributes' do
    expect(event).to be_valid
  end
end
