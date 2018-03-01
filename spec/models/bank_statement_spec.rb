require 'spec_helper'

describe BankStatement do

  describe 'assotiations and fields' do
    it { should belong_to(:user) }
    it { should belong_to(:bank_account) }
    it { should have_many(:records) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:bank_account_id) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_presence_of(:year) }
    it { should validate_inclusion_of(:month).in_range(1..12).with_message(:invalid) }
  end

  describe '#name' do
    it 'use the English locale' do
      bank_statement = BankStatement.new(:year => 1985, :month => 5)
      expect(bank_statement.name).to eq("May 1985")
    end
  end

  describe '#validate_bank_account' do
    context 'when the bank account belongs to the user' do
      it 'should allow the creation of the statement' do
        user = FactoryGirl.create(:user)
        bank_account = FactoryGirl.create(:bank_account, :user_id => user.id)
        statement = BankStatement.new(:bank_account_id => bank_account.id, :user_id => user.id, :month => 1, :year => 2000)
        expect(statement.valid?).to be(true)
      end
    end

    context 'when the bank account does not belong to the user' do
      it 'should not allow to add/update a statement' do
        bank_account = FactoryGirl.create(:bank_account)
        other_user = FactoryGirl.create(:user)
        statement = BankStatement.new(:bank_account_id => bank_account.id, :user_id => other_user.id, :month => 1, :year => 2000)
        expect(statement.valid?).to be(false)
        expect_to_have_error(statement, :bank_account, :invalid)
      end
    end
  end

end
