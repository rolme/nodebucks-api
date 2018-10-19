require 'rails_helper'

RSpec.describe CryptosController, type: :controller do
  render_views

  describe "GET 'index'" do
    let!(:cryptos) { FactoryBot.create_list(:crypto, 6) }

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
    let!(:crypto) { FactoryBot.create(:dash) }

    before(:each) do
      VCR.use_cassette 'api_response' do
        get :show, params: { slug: crypto.slug }, format: :json
      end
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
end
