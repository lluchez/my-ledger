require 'spec_helper'

describe BankAccount do

  it { should belong_to(:user) }
  it { should belong_to(:parser) }
  it { should have_many(:statements) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:statement_parser_id) }

  describe '#latest_statement' do
    it 'should return nil when there are no statements' do
      bank_account = BankAccount.new
      expect(bank_account.latest_statement).to be_nil
    end

    it 'should return the one with the hight year/month' do
      statement_1 = BankStatement.new(:id => 1, :year => 2017, :month => 1, :created_at => Date.new(2017,1,1), :updated_at => Date.new(2017,1,1))
      statement_2 = BankStatement.new(:id => 1, :year => 2016, :month => 1, :created_at => Date.new(2017,1,2), :updated_at => Date.new(2017,1,2))
      statement_3 = BankStatement.new(:id => 1, :year => 2015, :month => 1, :created_at => Date.new(2017,1,3), :updated_at => Date.new(2017,1,3))
      # bank_account = FactoryBot.create(:account)
      bank_account = BankAccount.new
      expect(bank_account).to receive(:statements).and_return([statement_1, statement_2, statement_3])
      expect(bank_account.latest_statement).to eq(statement_1)
    end
  end

end
