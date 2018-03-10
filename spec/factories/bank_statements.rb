FactoryBot.define do
  factory :bank_statement do
    sequence(:month) { |n| (n % 12) + 1 }
    sequence(:year) { |n| (n / 12) + 2000 }
    total_amount 0
    # user
    # bank_account

    after(:build) do |bank_statement|
      users = [bank_statement.user, bank_statement.bank_account.try(:user)].compact.uniq
      raise "Mutiple users for bank_statement factory" if users.count > 1
      user = users.first || FactoryBot.create(:user)
      bank_statement.user ||= user
      if bank_statement.bank_account.nil?
        bank_statement.bank_account = FactoryBot.create(:bank_account, :user => user)
      else
        bank_statement.bank_account.update_attributes(:user => user) unless bank_statement.bank_account.user_id == user.id
      end
    end
  end
end
