require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe "GET 'index'" do
    let!(:users) { FactoryBot.create_list(:user, 3) }

    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
    end

    context 'when there is no additional params' do
      before(:each) do
        get :index, format: :json
      end

      it "returns a successful 200 response" do
        expect(response).to be_successful
      end

      it "returns list of users where email is present" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq users.size
      end
    end

    context 'when there is nonadmin param present' do
      before(:each) do
        FactoryBot.create(:user, admin: true)
        get :index, params: { nonadmin: true }, format: :json
      end

      it "returns a successful 200 response" do
        expect(response).to be_successful
      end

      it "returns list of users where email is present and are no admins" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq users.size
      end
    end

    context 'when there is verification_pending_users param present' do
      let!(:users) { FactoryBot.create_list(:user, 4, verification_status: :pending) }

      before(:each) do
        get :index, params: { verification_pending_users: true }, format: :json
      end

      it "returns a successful 200 response" do
        expect(response).to be_successful
      end

      it "returns list of users where verification_status is pending" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq users.size
      end
    end
  end

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
      expect(response).to be_successful
    end
  end

  describe "POST 'login'" do
    let!(:user) { FactoryBot.create(:user, email: 'user1@domain.com', password: '123', password_confirmation: '123') }

    before(:each) do
      post :login, params: { email: 'user1@domain.com', password: '123'} , format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end
  end

  describe "PATCH 'update'" do
    let!(:user) { FactoryBot.create(:user, password: '123', password_confirmation: '123', address: 'Address1') }

    before(:each) do
      controller.class.skip_before_action :authenticate_request, raise: false
      patch :update, params: { user: { address: 'Address2'}, slug: user.slug, current_password: '123' }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates user address" do
      expect(User.find(user.slug).address).to eq 'Address2'
    end
  end
end
