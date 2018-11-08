require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let!(:crypto) { FactoryBot.create(:bitcoin) }
  let(:transaction) { FactoryBot.create(:transaction) }

  it { should belong_to(:account) }
  it { should belong_to(:reward) }
  it { should belong_to(:withdrawal) }

  it 'is valid with valid attributes' do
    expect(transaction).to be_valid
  end

  it 'is invalid without at least one reference' do
    expect(Transaction.new(txn_type: 'deposit', amount: 100, status: :pending).valid?).to be false
  end

  describe '.pending' do
    let(:pending_transactions) { FactoryBot.create_list(:transaction, 4, status: :pending) }

    it 'returns pending transactions' do
      expect(Transaction.pending).to eq pending_transactions
    end
  end

  describe '.processed' do
    let(:processed_transactions) { FactoryBot.create_list(:transaction, 3, status: :processed) }

    it 'returns processed transactions' do
      expect(Transaction.processed).to eq processed_transactions
    end
  end

  describe '.cancelled' do
    let(:cancelled_transactions) { FactoryBot.create_list(:transaction, 2, status: :cancelled) }

    it 'returns cancelled transactions' do
      expect(Transaction.cancelled).to eq cancelled_transactions
    end
  end

  describe '#name' do
    it 'returns cached crypto name' do
      expect(transaction.name).to eq transaction.reward.name
    end
  end

  describe '#symbol' do
    it 'returns cached crypto symbol' do
      expect(transaction.symbol).to eq transaction.reward.symbol
    end
  end

  describe '#cancel!' do
    before(:each) do
      transaction.cancel!
    end

    it 'updates status to cancelled' do
      expect(transaction.status).to eq 'cancelled'
    end

    it 'sets cancelled_at to current time' do
      expect(transaction.cancelled_at).not_to be nil
    end
  end

  describe '#process!' do
    it 'updates status to processed' do
      transaction.process!
      expect(transaction.status).to eq 'processed'
    end
  end

  describe '#undo!' do
    it 'update status to pending' do
      transaction.undo!
      expect(transaction.status).to eq 'pending'
    end
  end

  describe '#reverse!' do
    context 'when txn_type is transfer' do
      let(:transaction) { FactoryBot.create(:transaction, txn_type: :transfer) }

      it 'sets status of transaction to cancelled' do
        transaction.reverse!
        expect(transaction.status).to eq 'cancelled'
      end
    end

    context 'when txn_type is deposit' do
      let(:account) { FactoryBot.create(:account, balance: 100) }
      let!(:transaction) { FactoryBot.create(:transaction, account: account, txn_type: :deposit, amount: 20) }

      it 'creates new transaction' do
        expect { transaction.reverse! }.to change(Transaction, :count).by(1)
      end

      it 'creates new transaction with withdrawal txn_type' do
        transaction.reverse!
        expect(account.transactions.second.txn_type).to eq 'withdraw'
      end

      it 'updates account balance' do
        transaction.reverse!
        expect(transaction.account.balance).to eq 80
      end

      it 'updates transaction status to processed' do
        transaction.reverse!
        expect(account.transactions.second.status).to eq 'processed'
      end
    end

    context 'when txn_type is withdraw' do
      context 'when withdrawal is present and transaction note includes specific message' do
        let(:user) { FactoryBot.create(:user, affiliate_balance: 100) }
        let(:withdrawal) { FactoryBot.create(:withdrawal, user: user) }
        let!(:transaction) { FactoryBot.create(:transaction, withdrawal: withdrawal, txn_type: :withdraw, amount: 20, notes: "Affiliate reward withdrawal") }

        it 'creates new transaction' do
          expect { transaction.reverse! }.to change(Transaction, :count).by(1)
        end

        it 'creates new transaction with deposit txn_type' do
          transaction.reverse!
          expect(withdrawal.transactions.second.txn_type).to eq 'deposit'
        end

        it 'updates user affiliate_balance' do
          transaction.reverse!
          expect(user.reload.affiliate_balance).to eq 120
        end

        it 'updates transaction status to processed' do
          transaction.reverse!
          expect(withdrawal.transactions.second.status).to eq 'processed'
        end
      end

      context 'when withdrawal is not present' do
        let(:account) { FactoryBot.create(:account, balance: 100) }
        let!(:transaction) { FactoryBot.create(:transaction, account: account, txn_type: :withdraw, amount: 20) }

        it 'creates new transaction' do
          expect { transaction.reverse! }.to change(Transaction, :count).by(1)
        end

        it 'creates new transaction with deposit txn_type' do
          transaction.reverse!
          expect(account.transactions.second.txn_type).to eq 'deposit'
        end

        it 'updates account balance' do
          transaction.reverse!
          expect(transaction.account.balance).to eq 120
        end

        it 'updates transaction status to processed' do
          transaction.reverse!
          expect(account.transactions.second.status).to eq 'processed'
        end
      end
    end
  end
end
