FactoryBot.define do
  factory :base_statement_record_category_rule, :class => StatementRecordCategoryRules::CategoryRuleBase do
    sequence(:name) { |n| "Rule #{n}" }
    # user
    # category { FactoryBot.create(:statement_record_category) }

    after(:build) do |category_rule|
      users = [category_rule.user, category_rule.category.try(:user)].compact.uniq
      raise "Mutiple users for category_rule factory" if users.count > 1
      user = users.first || FactoryBot.create(:user)
      category_rule.user ||= user
      if category_rule.category.nil?
        category_rule.category = FactoryBot.create(:statement_record_category, :user => user)
      else
        category_rule.category.update_attributes(:user_id => user.id) unless category_rule.category.user.id == user.id
      end
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
