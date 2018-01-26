FactoryGirl.define do
  factory :bank_account do
    sequence(:name) { |n| "bank-account#{n}" }
    user
    statement_parser { FactoryGirl.create(:plain_text_parser) }
  end
end
