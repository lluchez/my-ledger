FactoryGirl.define do
  factory :statement_record do
    # user
    # category
    # category_rule
    statement { FactoryGirl.create(:bank_statement) }
    amount 1 + Random.rand(300) + (Random.rand(10) / 10.0)
    date Date.today
    # description "Description"
    sequence(:description) { |n| "Description #{n}" }

    after(:build) do |statement_record|
      statement_record.user = statement_record.statement.user
    end

    trait :with_record_category do
      after(:build) do |statement_record|
        user = statement_record.user || statement_record.statement.user
        statement_record.category = FactoryGirl.create(:statement_record_category, :user => user)
      end
    end

    trait :with_category_rule do
      after(:build) do |statement_record|
        user = statement_record.user || statement_record.statement.user
        rule = FactoryGirl.create(:statement_record_category, :user => user)
        statement_record.category = rule
        statement_record.rule = FactoryGirl.create(:base_statement_record_category_rule, :user => use, :rule => rule)
      end
    end
  end
end
