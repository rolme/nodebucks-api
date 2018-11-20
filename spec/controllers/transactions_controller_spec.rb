require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  render_views

  describe "GET 'index'" do
    let!(:pending_transactions) { FactoryBot.create_list(:transaction, 2, status: :pending) }
    let!(:processed_transactions) { FactoryBot.create_list(:transaction, 3, status: :processed) }
    let!(:cancelled_transactions) { FactoryBot.create_list(:transaction, 2, status: :cancelled) }

    before(:each) do
      controller.class.skip_before_action :authenticate_admin_request, raise: false
      get :index, params: { limit: 10 }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "returns pending transactions" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['pending'].size).to eq pending_transactions.size
    end

    it "returns processed transactions" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['processed'].size).to eq processed_transactions.size
    end

    it "returns cancelled transactions" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['cancelled'].size).to eq cancelled_transactions.size
    end
  end

  describe "PATCH 'update'" do
    let!(:transaction) { FactoryBot.create(:transaction, status: :cancelled, amount: 10) } 

    before(:each) do
      patch :update, params: { slug: transaction.slug,  transaction: { status: :pending, amount: 30 } }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    it "updates status to pending" do
      expect(Transaction.find(transaction.slug).status).to eq 'pending'
    end

    it "updates amount" do
      expect(Transaction.find(transaction.slug).amount).to eq 30
    end
  end

  describe "PATCH 'processed'" do
    let!(:transaction) { FactoryBot.create(:transaction, status: :cancelled, amount: 10) } 

    before(:each) do
      patch :processed, params: { transaction_slug: transaction.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    context 'when withdrawal is not present' do
      it "updates status to processed" do
        expect(Transaction.find(transaction.slug).status).to eq 'processed'
      end
    end

    context 'when withdrawal is present' do
      let!(:withdrawal) { FactoryBot.create(:withdrawal_with_transactions) }
      let!(:transaction) { FactoryBot.create(:transaction, status: :pending, withdrawal: withdrawal) } 

      it "updates status to processed" do
        expect(Transaction.find(transaction.slug).status).to eq 'processed'
      end
    end
  end

  describe "PATCH 'undo'" do
    let!(:transaction) { FactoryBot.create(:transaction, status: :cancelled, amount: 10) } 

    before(:each) do
      patch :undo, params: { transaction_slug: transaction.slug }, format: :json
    end

    it "returns a successful 200 response" do
      expect(response).to be_successful
    end

    context 'when withdrawal is not present' do
      it "updates transaction status to pending" do
        expect(Transaction.find(transaction.slug).status).to eq 'pending'
      end
    end

    context 'when withdrawal is present' do
      let!(:withdrawal) { FactoryBot.create(:withdrawal_with_transactions) }
      let!(:transaction) { FactoryBot.create(:transaction, status: :pending, withdrawal: withdrawal) } 

      it "updates transaction and withdrawal status to pending" do
        expect(Transaction.find(transaction.slug).status).to eq 'pending'
        expect(Transaction.find(transaction.slug).withdrawal.status).to eq 'pending'
      end
    end
  end
end
