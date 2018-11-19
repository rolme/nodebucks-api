require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  render_views

  describe "GET 'index'" do
    let!(:contacts) { FactoryBot.create_list(:contact, 5, reviewed_at: nil) }

    before(:each) do
      get :index, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns all unreviewed contacts" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.size).to eq contacts.size
    end
  end

  describe "POST 'create'" do
    before(:each) do |test|
      unless test.metadata[:skip_before]
        post :create, params: { contact: { subject: 'Contact Subject', email: 'test@domain.com', message: 'Contact Message' } }, format: :json
      end
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "saves new contact", :skip_before do
      expect {
        post :create, params: { contact: { subject: 'Contact Subject', email: 'test@domain.com', message: 'Contact Message' } }, format: :json
      }.to change(Contact, :count).by(1)
    end
  end

  describe "PATCH 'reviewed'" do
    let(:contact) { FactoryBot.create(:contact)}
    let(:user) { FactoryBot.create(:user) }

    before(:each) do
      patch :reviewed, params: { contact_id: contact.id, user_slug: user.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates reviewed_at field" do
      expect(Contact.find(contact.id).reviewed_at).not_to be nil
    end
  end
end
