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

  describe "PATCH 'profile'" do
    let!(:user) { FactoryBot.create(:user, password: '123', password_confirmation: '123', address: 'Address1') }

    before(:each) do
      patch :profile, params: { user: { address: 'Address2'}, user_slug: user.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates user profile" do
      expect(User.find(user.slug).address).to eq 'Address2'
    end
  end

  describe "PATCH 'reset'" do
    let!(:user) { FactoryBot.create(:user, email: 'user1@domain.com') }

    before(:each) do
      patch :reset, params: { email: 'user1@domain.com', user_slug: user.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "creates reset token" do
      expect(User.find(user.slug).reset_token).not_to be_empty
    end
  end

  describe "PATCH 'reset_password'" do
    let!(:user) { FactoryBot.create(:user, email: 'user1@domain.com') }

    before(:each) do
      patch :reset, params: { email: 'user1@domain.com', user_slug: user.slug }, format: :json
      patch :reset_password, params: { user_slug: user.reload.reset_token, user: { password: '123', password_confirmation: '123'} }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "sets new user password" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['message']).to eq 'Password has been updated.'
    end
  end

  describe "POST 'admin_login'" do
    let!(:user) { FactoryBot.create(:user, email: 'admin@domain.com', password: '123', password_confirmation: '123', admin: true) }

    before(:each) do
      post :admin_login, params: { email: 'admin@domain.com', password: '123'} , format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end
  end

  describe "GET 'balance'" do
    let!(:user) { FactoryBot.create(:user, email: 'admin@domain.com', password: '123', password_confirmation: '123', admin: true) }

    before(:each) do
      controller.class.skip_before_action :authenticate_request, raise: false
      allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user))
      get :balance, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns user data" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).not_to be_empty
    end
  end

  describe "GET 'referrer'" do
    let!(:user) { FactoryBot.create(:user, email: 'admin@domain.com', password: '123', password_confirmation: '123', admin: true) }

    before(:each) do
      allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user))
      get :referrer, format: :json
    end

    it "returns referrer data" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).not_to be_empty
    end
  end

  describe "GET 'confirm'" do
    let!(:user) { FactoryBot.create(:user, confirmed_at: nil ) }

    before(:each) do
      get :confirm, params: { user_slug: user.slug }, format: :json
    end

    it "updates confirmed_at field" do
      expect(User.find(user.slug).confirmed_at).not_to be nil
    end
  end

  # TODO: Possibly broken action
  # describe "GET 'verify'" do
  #   let!(:user) { FactoryBot.create(:user, email: 'user1@domain.com' ) }

  #   before(:each) do
  #     get :verify, params: { user_slug: user.slug, user: { new_email: 'user2@domain.com'} }, format: :json
  #   end

  #   it "sets new email" do
  #     expect(User.find(user.slug).email).to eq 'user2@domain.com'
  #   end
  # end

  describe "DELETE 'destroy'" do
    let!(:user) { FactoryBot.create(:user) }

    before(:each) do
      controller.class.skip_before_action :authenticate_request, raise: false
      allow(controller).to receive(:current_user).and_return(user)
      delete :destroy, params: { slug: user.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "removes current user" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['message']).to eq 'User account has been removed.'
    end
  end

  describe "GET 'show'" do
    let!(:user) { FactoryBot.create(:user) }

    before(:each) do
      get :show, params: { slug: user.slug }, format: :json
    end

    it "returns user data" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).not_to be_empty
    end
  end

  describe "POST 'password_confirmation'" do
    let!(:user) { FactoryBot.create(:user, password: '123', password_confirmation: '123') }

    before(:each) do
      post :password_confirmation, params: { user_slug: user.slug, user: { password: '123' } }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end
  end
end
