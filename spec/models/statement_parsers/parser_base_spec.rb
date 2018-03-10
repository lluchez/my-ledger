require 'spec_helper'

describe StatementParsers::ParserBase do

  it { should have_many(:bank_accounts) }

  it { should_not allow_value(nil).for(:type) }
  it { should_not allow_value("").for(:type) }
  it { should_not allow_value("UnknownParser").for(:type) }
  it { should allow_value("PlainTextParser").for(:type) }

  describe '#type' do
    context 'missing type' do
      it 'model should be invalid' do
        parser = FactoryBot.build(:base_parser, :type => nil)
        expect(parser.valid?).to eq(false)
        expect_to_have_error(parser, :type, :blank)
      end
    end

    context 'invalid type' do
      it 'model should be invalid' do
        parser = FactoryBot.build(:base_parser, :type => 'UnknownParser')
        expect(parser.valid?).to eq(false)
        expect_to_have_error(parser, :type, :invalid)
      end
    end

    context 'type' do
      it 'model should be valid' do
        parser = FactoryBot.build(:plain_text_parser)
        expect(parser.valid?).to eq(true)
      end
    end
  end

  describe '#classname_from_type' do
    it 'should return the passed type if accepted' do
      StatementParsers::ParserBase::types.each do |type|
        expect(StatementParsers::ParserBase::classname_from_type(type)).to eq(type)
      end
    end
    it 'should return nil when the passed type is is not valid' do
      expect(StatementParsers::ParserBase::classname_from_type("Invalid")).to be_nil
      expect(StatementParsers::ParserBase::classname_from_type(nil)).to be_nil
    end
  end

  describe '#before_destroying' do
    it 'should prevent deletion of a parser if linked to a bank account' do
      user = FactoryBot.create(:user)
      parser = FactoryBot.create(:plain_text_parser)
      account = FactoryBot.create(:bank_account, :statement_parser_id => parser.id, :user_id => user.id)
      expect {
        parser.destroy
      }.to_not change { StatementParsers::ParserBase.count }
    end
    it 'should allow deletion of a parser not linked to any bank account' do
      parser = FactoryBot.create(:plain_text_parser)
      expect {
        parser.destroy
      }.to change { StatementParsers::ParserBase.count }.by(-1)
    end
  end

end
