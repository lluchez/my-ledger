class StatementRecord < ApplicationRecord
  belongs_to :user, :validate => true
  belongs_to :statement, :validate => true, :class_name => BankStatement.to_s
  belongs_to :category, :optional => true, :class_name => StatementRecordCategory.to_s
  belongs_to :category_rule, :optional => true, class_name: StatementRecordCategoryRules::CategoryRuleBase.to_s
  has_one :bank_account, :through => :statement

  audited :associated_with => :statement

  scope :from_user, ->(user) { where(:user_id => user.id) }
  scope :uncategorized, ->{ where(:category_id => nil) }

  validates_presence_of :user_id, :statement_id, :amount, :date, :description

  before_validation :unset_category_rule, :if =>  Proc.new { |record| record.category_id_changed? && record.category_rule_id_was.present? }
  before_save :search_and_apply_matching_rule, :if => Proc.new { |record| record.description_changed? && record.category_id.nil? }
  after_save :update_statement_total_amount_after_save
  after_destroy :update_statement_total_amount_after_destroy

  alias_attribute :name, :description

  def self.import(csv_file, statement, remove_existing_records, user = nil)
    BankStatementsCsvImport.new(user).import(statement, csv_file, remove_existing_records)
  end

  def search_and_apply_matching_rule
    rule = self.find_matching_rule
    return unless rule.present?
    self.apply_matching_rule(rule)
  end

  def apply_matching_rule(rule)
    if rule.try(:user_id) != self.user_id
      RollbarHelper.warning("Tried to apply the Rule #{rule} with Record #{self}, but user_id don't match", :fingerprint => 'user_id_mismatch_for_apply_rule')
      return
    end
    self.assign_attributes(:category_rule_id => rule.id, :category_id => rule.category_id)
  end

  def apply_matching_rule!(rule)
    self.apply_matching_rule(rule)
    self.save!
  end

  def find_matching_rule
    StatementRecordCategoryRules::CategoryRuleBase.from_user(self.user).active.find { |r| r.matches?(self.description) }
  end

  def update_statement_total_amount_after_save
    # NOTE: upgrading to Rails 5.2.0 (from 5.0.6) requires to use `previously_`/`previous_`
    if id_previously_changed? # id_changed?
      update_statement_total_amount_by(self.amount)
    elsif amount_previously_changed? # amount_changed?
      update_statement_total_amount_by(self.amount - self.amount_previous_change[0]) # self.amount_was
    end
  end

  def update_statement_total_amount_after_destroy
    update_statement_total_amount_by(0 - self.amount)
  end

  private

  def unset_category_rule
    self.category_rule_id = nil
  end

  def update_statement_total_amount_by(value)
    self.statement.update_attributes(:total_amount => self.statement.total_amount + value)
  end
end
