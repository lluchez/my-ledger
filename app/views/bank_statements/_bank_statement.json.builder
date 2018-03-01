json.extract! bank_statement, :id, :name, :year, :month, :total_amount, :created_at, :updated_at
json.parser bank_account.bank_account, partial: 'bank_accounts/bank_account', as: :bank_account
json.url bank_statement_url(bank_account, format: :json)
