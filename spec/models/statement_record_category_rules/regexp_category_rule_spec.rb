require 'spec_helper'

describe StatementRecordCategoryRules::RegexpCategoryRule do

  describe '#validate_specific_fields' do
    context 'RegexpCategoryRule' do
      let(:user) { FactoryGirl.create(:user) }
      let(:record_category) { FactoryGirl.create(:statement_record_category, :user => user) }
      let(:attrs) { FactoryGirl.attributes_for(:regexp_category_rule).merge(:user => user, :category_id => record_category.id) }

      it 'should require a regexp to parse statement records' do
        rule = StatementRecordCategoryRules::CategoryRuleBase.new(attrs.merge(:pattern => nil))
        expect(rule.valid?).to eq(false)
        expect_to_have_error(rule, :pattern, :blank)
      end

      it 'should require a valid regexp to parse statement records' do
        rule = StatementRecordCategoryRules::CategoryRuleBase.new(attrs.merge(:pattern => '('))
        expect(rule.valid?).to eq(false)
        expect_to_have_error(rule, :pattern, :invalid_regexp, :err_msg => "end pattern with unmatched parenthesis: /(/")
      end

      it 'should accept valids regexp to parse statement records' do
        rule = StatementRecordCategoryRules::CategoryRuleBase.new(attrs)
        expect(rule.valid?).to eq(true)
      end
    end
  end

end
