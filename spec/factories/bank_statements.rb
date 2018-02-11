FactoryGirl.define do
  factory :bank_statement do
    user
    bank_account
    sequence(:month) { |n| (n % 12) + 1 }
    sequence(:year) { |n| (n / 12) + 2000 }
    total_amount 0

    after(:build) do |bank_statement|
      user = bank_statement.user || bank_statement.bank_account.try(:user)
      bank_statement.user = user
      bank_statement.bank_account.update_attributes(:user => user) unless bank_statement.bank_account.nil? || bank_statement.bank_account.user == user
    end
  end
end
