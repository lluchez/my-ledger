class StatementRecordCategoryRules::CategoryRuleBase < ApplicationRecord
  before_destroy :before_destroying # to declare before any `:has_many :dependend => :destroy`

  belongs_to :user, :optional => true
  belongs_to :category, :optional => true, :class_name => StatementRecordCategory, :foreign_key => :category_id
  has_many :records, :class_name => StatementRecord, :foreign_key => :category_rule_id

  validates_presence_of :name, :pattern, :user_id, :category_id
  validate :type_should_be_valid
  validate :validate_specific_fields

  self.inheritance_column = :type
  self.table_name = "statement_record_category_rules"

  scope :active, ->{ where(:active => true) }

  def self.types
    %w(TextCategoryRule RegexpCategoryRule)
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
        errors.add(:type, "Rule type is required")
      elsif !self.class.types.include?(self.type)
        errors.add(:type, "Invalid rule type")
      end
    end

    def validate_specific_fields
      if self.type == 'RegexpCategoryRule'
        if self.pattern.present?
          begin
            ereg = Regexp.new(self.pattern)
          rescue
            errors.add(:pattern, "Invalid regular expression")
          end
        end
      end
    end

    def before_destroying
      if StatementRecord.where(:category_rule_id => self.id).any?
        errors.add(:base, "This rule is used and cannot be removed now")
        throw :abort
      end
    end
end