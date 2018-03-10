MODELS = {
  :bank_account => {
    :props  => [:id, :name, :parser_id => :statement_parser_id],
    :check_url => true
  },
  :bank_statement => {
    :props  => [:id, :name, :month, :year, :total_amount, :bank_account_id],
    :check_url => true
  },
  :statement_parser => {
    :props  => [:id, :name, :type, :plain_text_regex, :plain_text_date_format],
    :check_url => true
  },
  :statement_record => {
    :props  => [:id, :amount, :date, :description, :statement_id],
    :check_url => true
  }
}

def assert_json_bank_account(json, bank_account)
  assert_json_model(json, bank_account, :bank_account)
end

def assert_json_bank_statement(json, bank_statement)
  assert_json_model(json, bank_statement, :bank_statement)
end

def assert_json_statement_parser(json, statement_parser)
  assert_json_model(json, statement_parser, :statement_parser)
end

def assert_json_statement_record(json, statement_record)
  json = assert_json_model(json, statement_record, :statement_record)
end

def assert_json_model(json, model, type)
  json = json.deep_symbolize_keys
  data = MODELS[type]
  data[:props].each do |prop|
    json_prop = model_prop = prop
    json_prop, model_prop = prop.first if prop.class == Hash
    value = model.send(model_prop)
    value = value.to_s("%F") if value.class == Date
    expect(json[json_prop]).to eq(value)
  end
  if data[:check_url]
    expect(json[:url]).to match("/#{model.id}\.json$")
  end
  json
end

