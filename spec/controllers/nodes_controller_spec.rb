require 'rails_helper'

RSpec.describe NodesController, type: :controller do
  render_views
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let!(:crypto_price_buy) { FactoryBot.create(:crypto_price, crypto: crypto, amount: 10, price_type: :buy) }
  let!(:crypto_price_sell) { FactoryBot.create(:crypto_price, crypto: crypto, amount: 10, price_type: :sell) }

  describe "GET 'index'" do
    let!(:nodes) { FactoryBot.create_list(:node, 4, :skip_validate, crypto: crypto) }

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    context 'when params have all key' do
      let!(:nodes) { FactoryBot.create_list(:node, 4, :skip_validate, crypto: crypto, status: :online) }

      before(:each) do
        controller.class.skip_before_action :authenticate_request, raise: false
        allow(controller).to receive(:current_user).and_return(FactoryBot.create(:user, admin: true))
        get :index, params: { all: true }, format: :json
      end

      it "returns all unreserved nodes" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq nodes.size
      end
    end

    context "when params don't have all key" do
      let(:user) { FactoryBot.create(:user) }
      let!(:nodes) { FactoryBot.create_list(:node, 4, :skip_validate, crypto: crypto, user: user, status: :new) }

      before(:each) do
        controller.class.skip_before_action :authenticate_request, raise: false
        allow(controller).to receive(:current_user).and_return(user)
        get :index, format: :json
      end

      it "returns all nodes where status is offline, online or new" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.size).to eq nodes.size
      end
    end
  end

  # describe "POST 'create'" do
  #   before(:each) do |test|
  #     controller.class.skip_before_action :authenticate_request, raise: false
  #     controller.instance_variable_set(:@current_user, FactoryBot.create(:user, admin: true))
      
  #     CryptoPricer::AMOUNTS.each do |amount|
  #       FactoryBot.create(:crypto_price, crypto: crypto, amount: amount, price_type: :buy)
  #       FactoryBot.create(:crypto_price, crypto: crypto, amount: amount, price_type: :sell)
  #     end
  #   end

  #   it "creates new node" do
  #     expect {
  #       post :create, params: { crypto: crypto.slug }, format: :json
  #     }.to change(Node, :count).by(1)
  #   end
  # end

  # describe "POST 'generate'" do
  #   let!(:user) { FactoryBot.create(:user) }

  #   before(:each) do |test|
  #     controller.class.skip_before_action :authenticate_admin_request, raise: false
  #     controller.instance_variable_set(:@current_user, FactoryBot.create(:user))

  #     CryptoPricer::AMOUNTS.each do |amount|
  #       FactoryBot.create(:crypto_price, crypto: crypto, amount: amount, price_type: :buy)
  #       FactoryBot.create(:crypto_price, crypto: crypto, amount: amount, price_type: :sell)
  #     end
  #   end

  #   it "creates and purchase new node" do
  #     expect {
  #        post :generate, params: { node: { crypto_id: crypto.id, user_id: user.id, amount: 10000 } }, format: :json
  #     }.to change(Node, :count).by(1)
  #   end
  # end

  describe "PATCH 'offline'" do
    let!(:node) { FactoryBot.create(:node, crypto: crypto, status: :online) } 

    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      patch :offline, params: { node_slug: node.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates node status to offline" do
      expect(Node.find(node.slug).status).to eq 'offline'
    end
  end

  describe "PATCH 'online'" do
    let!(:node) { FactoryBot.create(:node, crypto: crypto, status: :offline, wallet: 'GZGDNpbFRUuz5fsSqnT6zwTcrJ9qB2rw2a') } 

    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      patch :online, params: { node_slug: node.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates node status to online" do
      expect(Node.find(node.slug).status).to eq 'online'
    end
  end

  # describe "PATCH 'reserve'" do
  #   let!(:node) { FactoryBot.create(:node, crypto: crypto, status: :online) } 

  #   before(:each) do
  #     controller.class.skip_before_action :authenticate_request, raise: false
  #     patch :offline, params: { node_slug: node.slug }, format: :json
  #   end

  #   it "returns a successful 200 response" do
  #     expect(response).to be_successful
  #   end

  #   it "updates node status to offline" do
  #     expect(Node.find(node.slug).status).to eq 'offline'
  #   end
  # end

  describe "PATCH 'restore'" do
    let!(:node) { FactoryBot.create(:node, crypto: crypto, deleted_at: Time.now) } 

    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      patch :restore, params: { node_slug: node.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates deleted_at to nil" do
      expect(Node.find(node.slug).deleted_at).to be nil
    end
  end
end
