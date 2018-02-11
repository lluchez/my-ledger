require 'spec_helper'

describe User do

  it { should have_many(:bank_accounts) }
  it { should have_many(:bank_statements) }
  it { should have_many(:statement_records) }
  it { should have_many(:statement_record_categories) }
  it { should have_many(:statement_record_category_rules) }
  it { should validate_presence_of(:name) }

end
