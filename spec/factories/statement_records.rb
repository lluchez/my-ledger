FactoryBot.define do
  factory :statement_record do
    amount 1 + Random.rand(300) + (Random.rand(10) / 10.0)
    date Date.today
    sequence(:description) { |n| "Description #{n}" }
    # user
    # category
    # category_rule
    # statement { FactoryBot.create(:bank_statement) }

    after(:build) do |statement_record|
      users = [:statement, :category, :category_rule].map{ |a| statement_record.send(a).try(:user) } + [statement_record.user]
      users = users.compact.uniq
      raise "Mutiple users for statement_record factory" if users.count > 1
      user = users.first || FactoryBot.create(:user)
      statement_record.user ||= user
      if statement_record.statement.nil?
        statement_record.statement = FactoryBot.create(:bank_statement, :user => user)
      else
        statement_record.statement.update_attributes(:user_id => user.id) unless statement_record.statement.user.id == user.id
      end
      # TO DO: update user_id attribute for category and category_rule
    end

    # trait :with_record_category do
    #   after(:build) do |statement_record|
    #     user = statement_record.user || statement_record.statement.user
    #     statement_record.category = FactoryBot.create(:statement_record_category, :user => user)
    #   end
    # end

    # trait :with_category_rule do
    #   after(:build) do |statement_record|
    #     user = statement_record.user || statement_record.statement.user
    #     rule = FactoryBot.create(:statement_record_category, :user => user)
    #     statement_record.category = rule
    #     statement_record.rule = FactoryBot.create(:base_statement_record_category_rule, :user => use, :rule => rule)
    #   end
    # end
  end
end
