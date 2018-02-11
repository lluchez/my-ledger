require 'spec_helper'

describe StatementRecordCategory do

  it { should belong_to(:user) }
  it { should have_many(:records) }
  it { should have_many(:rules) }
  it { should validate_presence_of(:name) }

  describe '#active' do
    it 'should only return active categories' do
      category_active = FactoryGirl.create(:statement_record_category)
      category_disabled = FactoryGirl.create(:statement_record_category, :active => false)
      expect(StatementRecordCategory.active).to eq([category_active])
    end
  end

  describe '#before_destroying' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should prevent deletion of a category if linked to a statement record' do
      category = FactoryGirl.create(:statement_record_category, :user_id => user.id)
      record = FactoryGirl.create(:statement_record, :user_id => user.id, :category_id => category.id)

      expect {
        category.destroy
      }.to_not change { StatementRecordCategory.count }
    end

    it 'should prevent deletion of a category if linked to a category rule' do
      category = FactoryGirl.create(:statement_record_category, :user_id => user.id)
      rule = FactoryGirl.create(:text_category_rule, :user_id => user.id, :category_id => category.id)

      expect {
        category.destroy
      }.to_not change { StatementRecordCategory.count }
    end

    it 'should allow deletion of a category not linked to any statement record nor category rule' do
      category = FactoryGirl.create(:statement_record_category, :user_id => user.id)

      expect {
        category.destroy
      }.to change { StatementRecordCategory.count }.by(-1)
    end
  end

end
