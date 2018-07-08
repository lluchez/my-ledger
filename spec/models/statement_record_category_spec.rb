require 'spec_helper'

describe StatementRecordCategory do

  describe 'assotiations and fields' do
    it { should belong_to(:user) }
    it { should have_many(:records) }
    it { should have_many(:rules) }
    it { should validate_presence_of(:name) }

    it { should allow_value('').for(:icon) }
    it { should allow_value(nil).for(:icon) }
    it { should allow_value('').for(:color) }
    it { should allow_value(nil).for(:color) }
    it { should allow_value('rgb(1,2,3)').for(:color) }
    it { should allow_value('rgb(255,255,255)').for(:color) }
    it { should allow_value('#0Af').for(:color) }
    it { should allow_value('#00AAff').for(:color) }
    it { should_not allow_value('anything').for(:color) }
    it { should_not allow_value('rgb (1,1,1)').for(:color) }
    it { should_not allow_value('rgb(1000,1,1)').for(:color) }
    it { should_not allow_value('#1').for(:color) }
    it { should_not allow_value('#1234').for(:color) }
  end

  describe 'audited' do
    before(:each) { described_class.auditing_enabled = true }
    after(:each) { described_class.auditing_enabled = true }

    it { should be_audited }
    it { should have_associated_audits }
  end

  describe '#active' do
    it 'should only return active categories' do
      category_active = FactoryBot.create(:statement_record_category)
      category_disabled = FactoryBot.create(:statement_record_category, :active => false)
      expect(StatementRecordCategory.active).to eq([category_active])
    end
  end

  describe '#before_destroying' do
    let(:user) { FactoryBot.create(:user) }

    it 'should prevent deletion of a category if linked to a statement record' do
      category = FactoryBot.create(:statement_record_category, :user_id => user.id)
      record = FactoryBot.create(:statement_record, :user_id => user.id, :category_id => category.id)

      expect {
        category.destroy
      }.to_not change { StatementRecordCategory.count }
    end

    it 'should prevent deletion of a category if linked to a category rule' do
      category = FactoryBot.create(:statement_record_category, :user_id => user.id)
      rule = FactoryBot.create(:text_category_rule, :user_id => user.id, :category_id => category.id)

      expect {
        category.destroy
      }.to_not change { StatementRecordCategory.count }
    end

    it 'should allow deletion of a category not linked to any statement record nor category rule' do
      category = FactoryBot.create(:statement_record_category, :user_id => user.id)

      expect {
        category.destroy
      }.to change { StatementRecordCategory.count }.by(-1)
    end
  end

end
