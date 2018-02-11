FactoryGirl.define do
  factory :base_statement_record_category_rule, :class => StatementRecordCategoryRules::CategoryRuleBase do
    sequence(:name) { |n| "Rule #{n}" }
    user
    category { FactoryGirl.create(:statement_record_category) }

    after(:build) do |category_rule|
      user = category_rule.user || category_rule.category.try(:user)
      category_rule.user = user
      category_rule.category.update_attributes(:user => user) unless category_rule.category.nil? || category_rule.category.user == user
    end

    factory :text_category_rule, :class => StatementRecordCategoryRules::TextCategoryRule do
      type 'TextCategoryRule'
      pattern 'ABC'
      case_insensitive false
    end

    factory :regexp_category_rule, :class => StatementRecordCategoryRules::RegexpCategoryRule do
      type 'RegexpCategoryRule'
      pattern 'ABC'
      case_insensitive false
    end

  end
end
