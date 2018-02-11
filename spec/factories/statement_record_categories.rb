FactoryGirl.define do
  factory :statement_record_category do
    sequence(:name) { |n| "Category #{n}" }
    user
    color '#00F'
    icon "travel"
    active true
  end
end
