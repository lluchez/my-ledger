require 'spec_helper'

describe StatementRecord do

  it { should belong_to(:user) }
  it { should belong_to(:statement) }
  it { should belong_to(:category) }
  it { should belong_to(:category_rule) }

  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:statement_id) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:description) }

  describe '#update_statement_total_amount' do
    let!(:statement) { FactoryGirl.create(:bank_statement) }

    context 'on new record creation' do
      it 'should increment the value of total_amount of the statement' do
        amount = 142.99
        expect {
          record = FactoryGirl.create(:statement_record, :amount => amount, :statement => statement)
          expect(record.amount).to eq(amount)
        }.to change{ statement.total_amount }.by(amount)
      end
    end

    context 'on record updated' do
      it 'should update the value total_amount of the statement' do
        new_amount = 142.99
        expected_amount = new_amount + statement.total_amount
        record = FactoryGirl.create(:statement_record, :amount => 52.15, :statement => statement)
        record.update_attributes(:amount => new_amount)
        expect(statement.reload.total_amount).to eq(expected_amount)
      end
    end

    context 'on record deletion' do
      it 'should update the value total_amount of the statement' do
        expected_amount = statement.total_amount
        record = FactoryGirl.create(:statement_record, :amount => 52.15, :statement => statement)
        expect {
          record.destroy
        }.to change{ statement.total_amount }.by(0 - record.amount)
        expect(statement.reload.total_amount).to eq(expected_amount)
      end
    end
  end

end