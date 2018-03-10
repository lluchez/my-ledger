json.extract! bank_account, :id, :name
json.parser_id bank_account.statement_parser_id
json.parser_name bank_account.parser.name if bank_account.association(:parser).loaded?
json.url bank_account_url(bank_account, format: :json)