require 'spec_helper'

describe User do

  describe 'assotiations and fields' do
    it { should have_many(:bank_accounts) }
    it { should have_many(:bank_statements) }
    it { should have_many(:statement_records) }
    it { should have_many(:statement_record_categories) }
    it { should have_many(:statement_record_category_rules) }
    it { should validate_presence_of(:name) }
  end

  describe 'audited' do
    before(:each) { described_class.auditing_enabled = true }
    after(:each) { described_class.auditing_enabled = true }

    it { should be_audited }
  end

end
