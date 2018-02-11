class StatementRecord < ApplicationRecord
  belongs_to :user, :validate => true
  belongs_to :statement, :validate => true, :class_name => BankStatement
  belongs_to :category, :optional => true, :class_name => StatementRecordCategory
  belongs_to :category_rule, :optional => true, class_name: StatementRecordCategoryRules::CategoryRuleBase

  validates_presence_of :user_id, :statement_id, :amount, :date, :description

  after_save :update_statement_total_amount_after_save
  after_destroy :update_statement_total_amount_after_destroy

  def update_statement_total_amount_after_save
    if id_changed?
      update_statement_total_amount_by(self.amount)
    elsif amount_changed?
      update_statement_total_amount_by(self.amount - self.amount_was)
    end
  end

  def update_statement_total_amount_after_destroy
    update_statement_total_amount_by(0 - self.amount)
  end

  private def update_statement_total_amount_by(value)
    self.statement.update_attributes(:total_amount => self.statement.total_amount + value)
  end
end
