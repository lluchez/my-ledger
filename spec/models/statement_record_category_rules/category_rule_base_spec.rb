require 'spec_helper'

describe StatementRecordCategoryRules::CategoryRuleBase do

  describe 'assotiations and fields' do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
    it { should have_many(:records) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:pattern) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:category_id) }

    it { should_not allow_value(nil).for(:type) }
    it { should_not allow_value("").for(:type) }
    it { should_not allow_value("UnknownRule").for(:type) }
    it { should allow_value("TextCategoryRule").for(:type) }
    it { should allow_value("RegexpCategoryRule").for(:type) }
  end

  context 'audited' do
    before(:each) { described_class.auditing_enabled = true }
    after(:each) { described_class.auditing_enabled = false }

    it { should be_audited.associated_with(:category) }
  end

  describe '#active' do
    it 'should only return active rules' do
      rule_active = FactoryBot.create(:text_category_rule)
      rule_disabled = FactoryBot.create(:text_category_rule, :active => false)
      expect(StatementRecordCategoryRules::CategoryRuleBase.active).to eq([rule_active])
    end
  end

  describe '#classname_from_type' do
    it 'should return the passed type if accepted' do
      StatementRecordCategoryRules::CategoryRuleBase::types.each do |type|
        expect(StatementRecordCategoryRules::CategoryRuleBase::classname_from_type(type)).to eq(type)
      end
    end
    it 'should return nil when the passed type is is not valid' do
      expect(StatementRecordCategoryRules::CategoryRuleBase::classname_from_type("Invalid")).to be_nil
      expect(StatementRecordCategoryRules::CategoryRuleBase::classname_from_type(nil)).to be_nil
    end
  end

  describe '#before_destroying' do
    let(:user) { FactoryBot.create(:user) }
    let(:rule) { FactoryBot.create(:regexp_category_rule, :user => user) }

    it 'should prevent deletion of a rule if linked to a statement record' do
      record = FactoryBot.create(:statement_record, :user_id => user.id, :category_id => rule.category_id, :category_rule_id => rule.id)
      expect(record.category).to eq(rule.category)
      expect(record.category_rule).to eq(rule)

      expect {
        rule.destroy
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
    end
    it 'should allow deletion of a rule not linked to any statement record' do
      rule = FactoryBot.create(:regexp_category_rule, :user_id => user.id)
      expect {
        rule.destroy
      }.to change { StatementRecordCategoryRules::CategoryRuleBase.count }.by(-1)
    end
  end

  describe '#string_or_empty' do
    it 'should return an empty string when given anything else than a string' do
      expect(described_class.new.send(:string_or_empty, nil)).to eq('')
      expect(described_class.new.send(:string_or_empty, 5)).to eq('')
    end
    it 'should return the given string' do
      expect(described_class.new.send(:string_or_empty, 'Test')).to eq('Test')
    end
  end

end
