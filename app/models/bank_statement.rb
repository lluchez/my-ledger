class BankStatement < ApplicationRecord
  belongs_to :user, :validate => true
  belongs_to :bank_account, :validate => true
  has_many :records, :dependent => :destroy, :class_name => StatementRecord, :foreign_key => :statement_id

  scope :from_user, ->(user) { where(:user_id => user.id) }

  # attr_accessible :records_attributes
  accepts_nested_attributes_for :records

  validates_presence_of :user_id, :bank_account_id, :total_amount, :year
  validates_inclusion_of :month, :in => (1..12), :message => :invalid
  validate :validate_bank_account

  def validate_bank_account
    if self.user_id.present? && self.bank_account.present?
      errors.add(:bank_account, :invalid) unless self.bank_account.user_id == self.user_id
    end
  end

  def date
    Date.new(self.year, self.month, 1)
  end

  def name
    "#{Date::MONTHNAMES[month]} #{year}"
  end

  def get_records_attributes_from_raw_text(text)
    self.bank_account.parser.get_records_attributes_from_raw_text(text)
  end
end
