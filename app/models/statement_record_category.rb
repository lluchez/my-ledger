class StatementRecordCategory < ApplicationRecord
  before_destroy :before_destroying # to declare before any `:has_many :dependend => :destroy`

  belongs_to :user, :optional => true
  has_many :records, :class_name => StatementRecord, :foreign_key => :category_id
  has_many :rules, :class_name => StatementRecordCategoryRules::CategoryRuleBase, :foreign_key => :category_id

  audited
  has_associated_audits

  scope :from_user, ->(user) { where(:user_id => user.id) }
  scope :active, ->{ where(:active => true) }

  validates_presence_of :user_id, :name

  private

    def before_destroying
      where_clause = {:category_id => self.id}
      if StatementRecord.where(where_clause).any? || StatementRecordCategoryRules::CategoryRuleBase.active.where(where_clause).any?
        errors.add(:base, "This category is used and cannot be removed now")
        throw :abort
      end
    end
end
