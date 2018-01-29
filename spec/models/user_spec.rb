require 'spec_helper'

describe User do

  it { should have_many(:bank_accounts) }
  it { should validate_presence_of(:name) }

end
