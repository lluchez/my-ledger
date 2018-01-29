require 'spec_helper'

describe BankAccount do

  it { should belong_to(:user) }
  it { should belong_to(:statement_parser) }
  it { should validate_presence_of(:name) }

end
