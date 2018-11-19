require 'rails_helper'

RSpec.describe MasternodesController, type: :controller do
  render_views

  describe "GET 'index'" do
    let!(:masternodes) { FactoryBot.create_list(:crypto, 5) }

    before(:each) do
      get :index, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns all masternodes" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.size).to eq masternodes.size
    end
  end

  describe "GET 'show'" do
    let!(:masternode) { FactoryBot.create(:crypto) }
    let!(:user) { FactoryBot.create(:user) }
    let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: masternode, amount: 10, price_type: 'buy') }

    before(:each) do
      get :show, params: { slug: masternode.slug, user_slug: user.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns data of single masternode" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to_not be_nil
    end

    it "returns masternode with expected slug" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["slug"]).to eq masternode.slug
    end
  end
end
