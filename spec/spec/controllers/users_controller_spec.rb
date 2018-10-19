require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe "POST 'create'" do
    let!(:crypto) { FactoryBot.create(:bitcoin) }
    let!(:referrer) { FactoryBot.create(:user) }

    before(:each) do |test|
      post :create, params: { 
        user: { 
          password: 'password',
          password_confirmation: 'password',
          first: 'Test',
          last: 'Test',
          email: 'test@email.com',
        }, referrer_affiliate_key: referrer.affiliate_key

      } , format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_success
    end
  end
end
