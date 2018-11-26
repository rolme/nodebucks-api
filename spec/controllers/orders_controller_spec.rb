require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  render_views

  describe "GET 'index'" do
    let!(:orders) { FactoryBot.create_list(:order, 4) }

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    context 'when params have all key' do
      before(:each) do
        controller.class.skip_before_action :authenticate_request, raise: false
        allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user, admin: true))
        get :index, params: { all: true, limit: 10 }, format: :json
      end

      it "returns all orders" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq orders.size
      end

      it 'returns orders containing node information' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first['node']).not_to be_empty
      end

      it 'returns orders containing user information' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first['user']).not_to be_empty
      end
    end

    context "when params don't have all key" do
      let(:user) { FactoryBot.create(:user) }
      let!(:orders) { FactoryBot.create_list(:order, 2, user: user) }

      before(:each) do
        controller.class.skip_before_action :authenticate_request, raise: false
        allow(controller).to receive(:current_user).and_return(user)
        get :index, format: :json
      end

      it "returns all current user orders" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq orders.size
      end

      it 'returns orders containing node information' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first['node']).not_to be_empty
      end

      it 'returns orders containing user information' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first['user']).not_to be_empty
      end
    end
  end

  describe "GET 'show'" do
    let(:user) { FactoryBot.create(:user) }
    let!(:order) { FactoryBot.create(:order, user: user) }

    before(:each) do
      controller.class.skip_before_action :authenticate_request, raise: false
      allow(controller).to receive(:current_user).and_return(user)
      get :show, params: { slug: order.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns data of single order" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to_not be_nil
    end

    it "returns order with expected slug" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["slug"]).to eq order.slug
    end
  end

  describe "PATCH 'paid'" do
    let!(:order) { FactoryBot.create(:order) } 

    before(:each) do
      patch :paid, params: { order_slug: order.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates status to paid" do
      expect(Order.find(order.slug).status).to eq 'paid'
    end
  end

  describe "PATCH 'unpaid'" do
    let!(:order) { FactoryBot.create(:order) } 

    before(:each) do
      patch :unpaid, params: { order_slug: order.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates status to unpaid" do
      expect(Order.find(order.slug).status).to eq 'unpaid'
    end
  end

  describe "PATCH 'canceled'" do
    let!(:order) { FactoryBot.create(:order) } 

    before(:each) do
      patch :canceled, params: { order_slug: order.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates status to canceled" do
      expect(Order.find(order.slug).status).to eq 'canceled'
    end
  end

end
