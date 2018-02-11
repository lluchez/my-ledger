class BankStatement < ApplicationRecord
  belongs_to :user, :validate => true
  belongs_to :bank_account, :validate => true
  has_many :records, :dependent => :destroy, :class_name => StatementRecord, :foreign_key => :statement_id

  validates_presence_of :user_id, :bank_account_id, :total_amount, :year
  validates_inclusion_of :month, :in => (1..12)
end
