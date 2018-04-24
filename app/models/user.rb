class User < ApplicationRecord
  audited # see which fields shouldn't be audited

  has_many :bank_accounts, :dependent => :destroy
  has_many :bank_statements, :dependent => :destroy
  has_many :statement_records, :dependent => :destroy
  has_many :statement_record_categories, :dependent => :destroy
  has_many :statement_record_category_rules, :dependent => :destroy, :class_name => StatementRecordCategoryRules::CategoryRuleBase.to_s

  validates :name, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable
end
