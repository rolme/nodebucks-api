require 'rails_helper'

RSpec.describe CryptosController, type: :controller do
  render_views

  let(:crypto) { FactoryBot.create(:dash, status: :unactive) }
  let!(:crypto_price) { FactoryBot.create(:crypto_price, crypto: crypto, amount: 10, price_type: 'buy') }

  describe "GET 'index'" do
    let!(:cryptos) { FactoryBot.create_list(:crypto_with_price, 6, status: :active) }

    before(:each) do
      get :index, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns all active cryptos" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.size).to eq cryptos.size
    end
  end

  describe "GET 'show'" do
    before(:each) do
      get :show, params: { slug: crypto.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns data of single crypto" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to_not be_nil
    end

    it "returns crypto with expected slug" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["slug"]).to eq crypto.slug
    end
  end

  describe "GET 'purchasable_statuses'" do
    it 'returns purchasable statuses for cryptos' do
      get :purchasable_statuses, format: :json
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq ["Buy Node", "Contact Us", "Unavailable"]
    end
  end

  describe "PATCH 'update'" do
    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      patch :update, params: { slug: crypto.slug, crypto: { description: 'Updated Description' } }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates crypto correctly" do
      expect(Crypto.find(crypto.slug).description).to eq 'Updated Description'
    end
  end

  describe "PATCH 'relist'" do
    it "sets crypto listed field to true" do
      patch :relist, params: { crypto_slug: crypto.slug }, format: :json
      expect(Crypto.find(crypto.slug).is_listed).to be true
    end
  end

  describe "PATCH 'delist'" do
    it "sets crypto listed field to false" do
      patch :delist, params: { crypto_slug: crypto.slug }, format: :json
      expect(Crypto.find(crypto.slug).is_listed).to be false
    end
  end

  describe "GET 'test_reward_scraper'" do
    let(:crypto) { FactoryBot.create(:crypto, slug: 'polis', explorer_url: 'https://explorer.polispay.org/address/') }

    context 'when wallet is invalid' do
      it 'returns response with error status and message' do
        get :test_reward_scraper, params: { crypto_slug: crypto.slug, wallet: 'PKX1111EXaunMhSXwD88QEk8JLXbYn7z', date: "2018-01-01" }, format: :json
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['status']).to eq 'error'
        expect(parsed_response['message']).to eq 'Unable to find wallet.'
      end
    end
  end

  describe "GET 'prices'" do
    before(:each) do
      FactoryBot.create_list(:crypto_price_history, 6, crypto: crypto)
      get :prices, params: { crypto_slug: crypto.slug, days: 5, timeframe: 'daily' }, format: :json
    end

    it 'returns price history for crypto' do
      parsed_response = JSON.parse(response.body)
      key = parsed_response.first.keys.first

      expect(parsed_response.first[key]["circulating_supply"].to_f).to be > 0
      expect(parsed_response.first[key]["market_cap"].to_f).to be > 0 
      expect(parsed_response.first[key]["max_supply"].to_f).to be > 0 
      expect(parsed_response.first[key]["price_usd"].to_f).to be > 0 
      expect(parsed_response.first[key]["total_supply"].to_f).to be > 0 
      expect(parsed_response.first[key]["volume_24h"].to_f).to be > 0 
    end
  end
end
