require 'spec_helper'

describe StatementRecord do

  describe 'assotiations and fields' do
    it { should belong_to(:user) }
    it { should belong_to(:statement) }
    it { should belong_to(:category) }
    it { should belong_to(:category_rule) }
    it { should have_one(:bank_account) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:statement_id) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:description) }
  end

  describe 'audited' do
    before(:each) { described_class.auditing_enabled = true }
    after(:each) { described_class.auditing_enabled = true }

    it { should be_audited.associated_with(:statement) }
  end

  describe '#update_statement_total_amount' do
    let!(:statement) { FactoryBot.create(:bank_statement) }

    context 'on new record creation' do
      it 'should increment the value of total_amount of the statement' do
        amount = 142.99
        expect {
          record = FactoryBot.create(:statement_record, :amount => amount, :statement => statement)
          expect(record.amount).to eq(amount)
        }.to change{ statement.total_amount }.by(amount)
      end
    end

    context 'on record updated' do
      it 'should update the value total_amount of the statement' do
        diff = 100
        record = FactoryBot.create(:statement_record, :amount => 52.15, :statement => statement)
        expect {
          record.update_attributes(:amount => record.amount + diff)
        }.to change{ statement.reload.total_amount }.by(diff)
      end
    end

    context 'on record deletion' do
      it 'should update the value total_amount of the statement' do
        expected_amount = statement.total_amount
        record = FactoryBot.create(:statement_record, :amount => 52.15, :statement => statement)
        expect {
          record.destroy
        }.to change{ statement.total_amount }.by(0 - record.amount)
        expect(statement.reload.total_amount).to eq(expected_amount)
      end
    end
  end

  describe '#find_matching_rule' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user_rule) { FactoryBot.create(:regexp_category_rule, :pattern => '.') }
    let(:user_disabled_rule) { FactoryBot.create(:regexp_category_rule, :user => user, :pattern => '.', :active => false) }
    let(:user_text_rule) { FactoryBot.create(:text_category_rule, :user => user, :pattern => 'def') }
    let(:user_ereg_rule) { FactoryBot.create(:regexp_category_rule, :user => user, :pattern => '\d+') }

    it 'should not match rules from other users' do
      rules = [other_user_rule] # will actually create the rule(s)
      record = described_class.new(:user => user, :description => "Something")
      expect(record.find_matching_rule).to eq(nil)
    end

    it 'should not match disabled rules' do
      rules = [user_disabled_rule] # will actually create the rule(s)
      record = described_class.new(:user => user, :description => "Something")
      expect(record.find_matching_rule).to eq(nil)
    end

    it 'should find matching active rules' do
      rules = [other_user_rule, user_disabled_rule, user_text_rule, user_ereg_rule] # will actually create the rule(s)
      expect(described_class.new(:user => user, :description => "abcdefgh").find_matching_rule).to eq(user_text_rule)
      expect(described_class.new(:user => user, :description => "abc456").find_matching_rule).to eq(user_ereg_rule)
    end
  end

  describe '#apply_matching_rule' do
    let(:user) { FactoryBot.create(:user) }
    let!(:rule) { FactoryBot.create(:regexp_category_rule, :user => user, :pattern => '\d+') }

    it 'should not update category nor rule' do
      record = FactoryBot.create(:statement_record, :user => user, :description => 'Not matching')
      expect(record.category).to eq(nil)
      expect(record.category_rule).to eq(nil)
    end

    it 'should not update category nor rule on updates when there is already a category set' do
      category = FactoryBot.create(:statement_record_category, :user => user)
      record = FactoryBot.create(:statement_record, :user => user, :description => 'Mercer 312', :category => category)
      expect(record.category).to eq(category)
      expect(record.category_rule).to eq(nil)
    end

    it 'should save a reference of the rule used and update the category' do
      record = FactoryBot.create(:statement_record, :user => user, :description => 'Mercer 312')
      expect(record.category).to eq(rule.category)
      expect(record.category_rule).to eq(rule)
    end

    it 'should apply the rule upon updates too' do
      record = FactoryBot.create(:statement_record, :user => user, :description => 'Something')
      expect(record.category).to eq(nil)
      expect(record.category_rule).to eq(nil)

      record.update_attributes(:description => 'Mercer 312')
      expect(record.category).to eq(rule.category)
      expect(record.category_rule).to eq(rule)
    end
  end

  describe '#unset_category_rule' do
    let(:user) { FactoryBot.create(:user) }
    let!(:rule) { FactoryBot.create(:regexp_category_rule, :user => user, :pattern => '\d+') }

    it 'reset category_rule after changing the category manually' do
      record = FactoryBot.create(:statement_record, :user => user, :description => 'Mercer 312')
      expect(record.category).to eq(rule.category)
      expect(record.category_rule).to eq(rule)

      record.update_attributes(:category_id => nil)
      expect(record.category).to eq(nil)
      expect(record.category_rule).to eq(nil)
    end
  end

end
