require 'spec_helper'

describe StatementRecordCategoryRules::CategoryRuleBase do

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

  describe '#active' do
    it 'should only return active rules' do
      rule_active = FactoryGirl.create(:text_category_rule)
      rule_disabled = FactoryGirl.create(:text_category_rule, :active => false)
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
    let(:user) { FactoryGirl.create(:user) }
    let(:category) { FactoryGirl.create(:statement_record_category, :user_id => user.id) }

    it 'should prevent deletion of a rule if linked to a statement record' do
      rule = FactoryGirl.create(:regexp_category_rule, :user_id => user.id)
      record = FactoryGirl.create(:statement_record, :category_rule_id => rule.id, :user_id => user.id, :category_id => category.id)
      expect {
        rule.destroy
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
    end
    it 'should allow deletion of a rule not linked to any statement record' do
      rule = FactoryGirl.create(:regexp_category_rule, :user_id => user.id)
      expect {
        rule.destroy
      }.to change { StatementRecordCategoryRules::CategoryRuleBase.count }.by(-1)
    end
  end

end
