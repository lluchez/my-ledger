json.extract! bank_account, :id, :name, :created_at, :updated_at
json.parser bank_account.statement_parser, partial: 'statement_parsers/statement_parser', as: :statement_parser
json.url bank_account_url(bank_account, format: :json)
