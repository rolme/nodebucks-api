require 'rails_helper'

RSpec.describe AnnouncementsController, type: :controller do
  render_views

  describe "POST 'create'" do
    before(:each) do |test|
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      unless test.metadata[:skip_before]
        post :create, params: { announcement: { text: 'Text' } }, format: :json
      end
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "saves new announcement", :skip_before do
      expect {
        post :create, params: { announcement: { text: 'Text' } }, format: :json
      }.to change(Announcement, :count).by(1)
    end
  end

  describe "GET 'last'" do
    context 'when there is announcement' do
      let!(:announcement) { FactoryBot.create(:announcement) }

      it 'returns last announcement' do
        get :last, format: :json
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['text']).to eq announcement.text
      end
    end

    context 'when there is no announcement' do
      it 'returns no announcement message' do
        get :last, format: :json
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq 'No announcement to show'
      end
    end
  end
end
