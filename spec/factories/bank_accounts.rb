FactoryBot.define do
  factory :bank_account do
    sequence(:name) { |n| "bank-account#{n}" }
    user
    parser { FactoryBot.create(:plain_text_parser) }
  end
end
