class StatementParsers::PlainTextParser < StatementParsers::ParserBase

  def validate_specific_fields
    if self.plain_text_regex.blank?
      errors.add(:plain_text_regex, :blank)
    else
      self.validate_regexp_field
    end
    errors.add(:plain_text_date_format, :blank) if self.plain_text_date_format.blank?
  end

  def validate_regexp_field
    [:date, :description, :amount].each do |group_name|
      errors.add(:plain_text_regex, :missing_group, {:group_name => group_name.to_s}) unless "(?<#{group_name.to_s}>".in?(self.plain_text_regex)
    end
    begin
      ereg = self.create_regexp
    rescue RegexpError => e
      errors.add(:plain_text_regex, :invalid_regexp, {:err_msg => e.message})
    end
  end

  def create_regexp
    Regexp.new("^#{self.plain_text_regex}$")
  end

  def get_records_attributes_from_raw_text(text)
    attributes = []
    errors     = []

    text.split(/\r?\n/).each_with_index do |line, index|
      line_number = index + 1
      if line.present?
        begin
          attributes << self.parse_line(line, line_number)
        rescue StandardError => e
          errors << e.message
        end
      end
    end

    {
      :attributes => attributes,
      :errors     => errors
    }
  end

  def parse_line(line, line_number)
    err_prefix = "custom_errors.plain_text_statement_parser"
    m = self.create_regexp.match(line)
    raise StandardError.new(I18n.t("#{err_prefix}.line_format", :line_number => line_number)) unless m.present?
    missing_groups = [:date, :description, :amount].select { |group| m[group].blank? }
    raise StandardError.new(I18n.t("#{err_prefix}.missing_groups", :line_number => line_number, :missing_groups => missing_groups.join(', '))) if missing_groups.present?
    date = self.parse_date(m[:date])
    raise StandardError.new(I18n.t("#{err_prefix}.date_format", :line_number => line_number, :date => m[:date])) unless date.present?
    amount = self.parse_amount(m[:amount])
    description = m[:description].strip

    {
      :date        => date,
      :amount      => amount,
      :description => description
    }
  end

  def parse_date(date)
    Date.parse(date || '') # TO DO: needs to be revisited
    # self.plain_text_date_format isn't used
  rescue ArgumentError => e
    nil
  end

  def parse_amount(amount)
    amount.gsub(/[^\d\.\-+]/, '').to_d
  end

end
