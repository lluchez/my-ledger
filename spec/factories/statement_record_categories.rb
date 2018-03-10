FactoryBot.define do
  factory :statement_record_category do
    sequence(:name) { |n| "Category #{n}" }
    color '#00F'
    icon "travel"
    active true
    user
  end
end
