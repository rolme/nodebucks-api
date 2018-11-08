require 'rails_helper'

RSpec.describe Contact, type: :model do
  let!(:contact) { FactoryBot.create(:contact) }

  it { should belong_to(:reviewer) }

  it 'is valid with valid attributes' do
    expect(contact).to be_valid
  end

  describe '.unreviewed' do
    it 'returns not reviewed contacts' do
      expect(Contact.unreviewed).to eq([contact])
    end
  end
end
