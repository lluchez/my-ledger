require 'spec_helper'

describe BankStatement do

  it { should belong_to(:user) }
  it { should belong_to(:bank_account) }
  it { should have_many(:records) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:bank_account_id) }
  it { should validate_presence_of(:total_amount) }
  it { should validate_presence_of(:year) }
  it { should validate_inclusion_of(:month).in_range(1..12) }

end
