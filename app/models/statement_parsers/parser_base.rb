class StatementParsers::ParserBase < ApplicationRecord
  before_destroy :before_destroying
  validates_presence_of :name
  validate :type_should_be_valid
  validate :validate_specific_fields

  self.inheritance_column = :type
  self.table_name = "statement_parsers"

  has_many :bank_accounts, :foreign_key => 'statement_parser_id'

  def self.types
    %w(PlainTextParser)
  end

  def self.store_full_sti_class
    false
  end

  def self.classname_from_type(type)
    type if self.types.include?(type)
  end

  private
    def type_should_be_valid
      if self.type.blank?
        errors.add(:type, "Parser type is required")
      elsif !self.class.types.include?(self.type)
        errors.add(:type, "Invalid parser type")
      end
    end

    def validate_specific_fields
      if self.type == 'PlainTextParser'
        if self.plain_text_regex.blank?
          errors.add(:plain_text_regex, "Regular expression is required for Plain Text parsers")
        else
          begin
            ereg = Regexp.new(self.plain_text_regex)
          rescue
            errors.add(:plain_text_regex, "Invalid regular expression")
          end
        end
        errors.add(:plain_text_date_format, "Date format is required for Plain Text parsers") if self.plain_text_date_format.blank?
      end
    end

    def before_destroying
      if BankAccount.where(:statement_parser_id => self.id).any?
        errors.add(:base, "This parser is used and can not be remove now")
        throw :abort
      end
    end
end
