require 'spec_helper'

describe BankAccount do

  it { should belong_to(:user) }
  it { should belong_to(:parser) }
  it { should have_many(:statements) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:statement_parser_id) }

end
