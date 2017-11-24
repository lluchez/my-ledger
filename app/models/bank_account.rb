class BankAccount < ApplicationRecord
  belongs_to :user, :validate => true
  belongs_to :statement_parser, class_name: StatementParsers::ParserBase, :validate => true, :foreign_key => 'statement_parser_id'

  validates_presence_of :name
end
