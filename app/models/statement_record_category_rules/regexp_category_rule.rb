class StatementRecordCategoryRules::RegexpCategoryRule < StatementRecordCategoryRules::CategoryRuleBase

  def validate_specific_fields
    if self.pattern.present?
      begin
        ereg = Regexp.new(self.pattern)
      rescue RegexpError => e
        errors.add(:pattern, :invalid_regexp, {:err_msg => e.message})
      end
    else
      errors.add(:pattern, :blank)
    end
  end

end
