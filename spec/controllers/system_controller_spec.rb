require 'rails_helper'

RSpec.describe SystemController, type: :controller do
  render_views

  let(:system_user) { FactoryBot.create(:user, :skip_validate, id: User::SYSTEM_ACCOUNT_ID, email: nil) }
  let!(:setting) { FactoryBot.create(:setting, user: system_user, key: 'max float') }

  describe "GET 'index'" do
    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      get :index, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns reponse that contains balances" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['balances']).to_not be_nil
    end

    it "returns reponse that contains settings" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['settings']).to_not be_nil
    end

    it "returns reponse that contains unpaidAmount" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['unpaidAmount']).to_not be_nil
    end
  end

  describe "PATCH 'setting'" do
    before(:each) do
      patch :setting, params: { setting: { key: 'max float', value: 'New value'} }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates setting" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['settings'].first['value']).to eq 'New value'
    end
  end
end
