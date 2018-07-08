require 'csv'

class BankStatementsCsvParser
  include LocalesHelper

  def initialize(user = nil)
    @user = user
    @categories = user.present? ? StatementRecordCategory.from_user(user) : []
  end

  def parse(csv_file)
    rows = []
    errors = []

    get_rows(csv_file).each_with_index do |row, row_idx|
      begin
        rows << parse_line(row, row_idx + 2)
      rescue CsvRowParsingException => e
        errors << e
      end
    end

    if errors.present?
      raise CsvFileParsingException.new(errors, csv_file)
    else
      rows
    end
  end

private

  def get_rows(csv_file_or_buffer)
    if csv_file_or_buffer.respond_to?(:path)
      rows = CSV.foreach(csv_file_or_buffer.path, headers: true)
    else
      rows = CSV.parse(csv_file_or_buffer, headers: true)
    end
    rows.count # this is what will trigger the exception if any
    rows
  rescue StandardError => e
    new_exception = StandardError.new(get_translation("lib.bank_statements_csv_parser.invalid_csv_file", {message: e.message}))
    raise CsvFileParsingException.new([new_exception], csv_file_or_buffer)
  end

  def parse_line(row, index)
    {
      :description => parse_field(row, index, "description"),
      :date        => parse_field(row, index, "date"),
      :amount      => parse_field(row, index, "amount"),
      :category_id => parse_field(row, index, "category"),
    }.reject{ |k,v| v.nil? }
  end

  def parse_field(row, index, field_name)
    self.send("parse_#{field_name}", row[field_name] || row[field_name.humanize])
  rescue StandardError => e
    raise CsvRowParsingException.new(e.message, field_name, index)
  end

  def parse_description(description)
    raise StandardError.new(translate_error_message(:description)) unless description.present?
    description
  end

  def parse_date(date_str)
    raise StandardError.new(translate_error_message(:date)) unless date_str.present?

    # validating the format (YYYY-MM-DD or YYYY/MM/DD)
    m = /^(?<year>\d{4})(?<sep>[\/\-])(?<month>\d{2})\k<sep>(?<day>\d{2})$/.match(date_str)
    raise StandardError.new(translate_error_message(:date, :invalid_format)) unless m.present?

    # parsing the date
    sep = m["sep"]
    begin
      Date.parse(date_str, "%Y#{sep}%m#{sep}%d")
    rescue StandardError
      raise StandardError.new(translate_error_message(:date, :parsing_error))
    end
  end

  def parse_amount(amount)
    raise StandardError.new(translate_error_message(:amount)) unless amount.present?

    m = /^[\+\-]?[\d\, ]+(\.\d+)?+$/.match(amount)
    raise StandardError.new(translate_error_message(:amount, :invalid_format)) unless m.present?
    amount.gsub(/[^\d\.\-+]/, '').to_d
  end

  def parse_category(category_name)
    if category_name.blank? || @user.blank?
      nil
    else
      category_name.strip!
      category = @categories.find { |c| c.name.strip.casecmp(category_name).zero? }
      # TO DO: conditionally create the category when not found (if the user wants so)
      # if category.nil?
      #   category = StatementRecordCategory.create(:name => category_name, :user_id => @user.id)
      #   @categories << category
      # end
      category.try(:id)
    end
  end

  def translate_error_message(attribute, key = :blank)
    model_translation(:statement_record, attribute, key)
  end
end
