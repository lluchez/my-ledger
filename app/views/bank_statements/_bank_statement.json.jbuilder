json.extract! bank_statement, :id, :name, :year, :month #, :total_amount # https://github.com/rails/activesupport-json_encoder
json.total_amount bank_statement.total_amount.to_f
json.extract! bank_statement, :bank_account_id
json.bank_account_name bank_statement.bank_account.name if bank_statement.association(:bank_account).loaded?
json.url bank_statement_url(bank_statement, format: :json)
