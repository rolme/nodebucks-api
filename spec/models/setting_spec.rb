require 'rails_helper'

RSpec.describe Setting, type: :model do
  let(:setting) { FactoryBot.create(:setting) }

  it { should belong_to(:user) }

  it 'is valid with valid attributes' do
    expect(setting).to be_valid
  end
end
