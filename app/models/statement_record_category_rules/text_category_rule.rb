class StatementRecordCategoryRules::TextCategoryRule < StatementRecordCategoryRules::CategoryRuleBase

  def validate_specific_fields; end

  def matches?(description)
    if self.case_sensitive
      string_or_empty(description).include?(string_or_empty(self.pattern))
    else
      string_or_empty(description).downcase.include?(string_or_empty(self.pattern).downcase)
    end
  end

end
