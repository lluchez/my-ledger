class StatementParsers::ParserBase < ApplicationRecord
  before_destroy :before_destroying # to declare before any `:has_many :dependend => :destroy`

  has_many :bank_accounts, :foreign_key => 'statement_parser_id', :dependent => :destroy

  validates_presence_of :name
  validate :type_should_be_valid
  validate :validate_specific_fields

  self.inheritance_column = :type
  self.table_name = "statement_parsers"

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
        errors.add(:type, :blank)
      elsif !self.class.types.include?(self.type)
        errors.add(:type, :invalid)
      end
    end

    # to override in the inheriting class
    def validate_specific_fields; end

    def before_destroying
      if BankAccount.where(:statement_parser_id => self.id).any?
        errors.add(:base, :cant_delete_in_use)
        throw :abort
      end
    end
end
