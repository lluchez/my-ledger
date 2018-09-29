json.extract! category_rule, :id, :name, :type, :type_formatted, :category_id
json.category_name category_rule.category.name if category_rule.association(:category).loaded?
json.extract! category_rule, :pattern, :case_sensitive, :active
json.url statement_record_category_rule_url(category_rule, format: :json)
