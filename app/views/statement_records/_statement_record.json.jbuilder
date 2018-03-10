json.extract! statement_record, :id, :date, :description #, :amount # https://github.com/rails/activesupport-json_encoder
json.amount statement_record.amount.to_f
json.extract! statement_record, :statement_id
json.statement_name statement_record.statement.name if statement_record.association(:statement).loaded?
json.url statement_record_url(statement_record, format: :json)
