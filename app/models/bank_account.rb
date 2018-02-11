class BankAccount < ApplicationRecord
  validates_presence_of :name, :user_id, :statement_parser_id

  belongs_to :user, :validate => true
  belongs_to :parser, :validate => true, class_name: StatementParsers::ParserBase, :foreign_key => 'statement_parser_id'
  has_many :statements, :dependent => :destroy, :class_name => BankStatement

end
