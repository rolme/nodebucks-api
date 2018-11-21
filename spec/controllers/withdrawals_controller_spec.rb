require 'rails_helper'

RSpec.describe WithdrawalsController, type: :controller do
  render_views

  describe "GET 'index'" do
     let!(:withdrawals) { FactoryBot.create_list(:withdrawal, 4) }

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    context 'when params have all key' do
      before(:each) do
        controller.class.skip_before_action :authenticate_request, raise: false
        allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user, admin: true))
        get :index, params: { all: true }, format: :json
      end

      it "returns all withdrawals" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq withdrawals.size
      end
    end

    context "when params don't have all key" do
      let(:user) { FactoryBot.create(:user) }
      let!(:withdrawals) { FactoryBot.create_list(:withdrawal, 4, user: user, status: :pending) }
      let!(:reserved_withdrawals) { FactoryBot.create_list(:withdrawal, 2, user: user, status: :reserved) }

      before(:each) do
        controller.class.skip_before_action :authenticate_request, raise: false
        allow(controller).to receive(:current_user).and_return(user)
        get :index, format: :json
      end

      it "returns all current user withdrawals where status is not reserved" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq withdrawals.size
      end
    end
  end

  describe "GET 'show'" do
    let!(:withdrawal) { FactoryBot.create(:withdrawal) }

    before(:each) do
      get :show, params: { slug: withdrawal.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns data of single withdrawal" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to_not be_nil
    end

    it "returns withdrawal with expected slug" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["slug"]).to eq withdrawal.slug
    end
  end

  describe "POST 'create'" do
    before(:each) do |test|
      allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user))
      unless test.metadata[:skip_before]
        post :create, format: :json
      end
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "saves new withdrawal", :skip_before do
      expect {
         post :create, format: :json
      }.to change(Withdrawal, :count).by(1)
    end
  end

  describe "PATCH 'update'" do
    let!(:withdrawal) { FactoryBot.create(:withdrawal) }

    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user))
      patch :update, params: { slug: withdrawal.slug,  withdrawal: { status: :processed } }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates withdrawal status" do
      expect(Withdrawal.find(withdrawal.slug).status).to eq 'processed'
    end
  end

  describe "PATCH 'confirm'" do
    let!(:user) { FactoryBot.create(:user, password: '123', password_confirmation: '123') }
    let!(:withdrawal) { FactoryBot.create(:withdrawal, user: user, status: :reserved) }

    before(:each) do
      controller.class.skip_before_action :authenticate_request, raise: false
      allow(controller).to receive(:current_user).and_return(user)
      patch :update, params: { slug: withdrawal.slug, payment: 'BTC', withdrawal: { payment_type: 'Crpto', target: 'Target 2', password: '123' } }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates withdrawal target" do
      expect(Withdrawal.find(withdrawal.slug).target).to eq 'Target 2'
    end

    it "updates withdrawal payment type" do
      expect(Withdrawal.find(withdrawal.slug).payment_type).to eq 'Crypto'
    end
  end
end
