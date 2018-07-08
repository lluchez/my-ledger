class StatementRecordCategory < ApplicationRecord
  before_destroy :before_destroying # to declare before any `:has_many :dependend => :destroy`

  belongs_to :user, :optional => true
  has_many :records, :class_name => StatementRecord.to_s, :foreign_key => :category_id
  has_many :rules, :class_name => StatementRecordCategoryRules::CategoryRuleBase.to_s, :foreign_key => :category_id

  audited
  has_associated_audits

  scope :from_user, ->(user) { where(:user_id => user.id) }
  scope :active, ->{ where(:active => true) }

  validates_presence_of :user_id, :name
  validate :validate_color

  private

    def before_destroying
      where_clause = {:category_id => self.id}
      if StatementRecord.where(where_clause).any? || StatementRecordCategoryRules::CategoryRuleBase.active.where(where_clause).any?
        errors.add(:base, :cant_delete_in_use)
        throw :abort
      end
    end

    def validate_color
      if self.color.present?
        unless /^(rgb\(\d{1,3},\s*\d{1,3},\s*\d{1,3}\)|\#([\da-fA-F]{3}|[\da-fA-F]{6}))$/ =~ self.color
          errors.add(:color, :invalid)
        end
      end
    end
end
