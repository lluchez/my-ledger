require 'spec_helper'

describe StatementParsers::ParserBase do

  it { should have_many(:bank_accounts) }

  it { should_not allow_value(nil).for(:type) }
  it { should_not allow_value("").for(:type) }
  it { should_not allow_value("UnknownParser").for(:type) }
  it { should allow_value("PlainTextParser").for(:type) }


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

  describe '#validate_specific_fields' do
    context 'PlainTextParser' do
      let(:attrs) { FactoryGirl.attributes_for(:plain_text_parser) }

      it 'should require a regexp to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_regex => nil))
        expect(parser.valid?).to eq(false)
        expect(parser.errors[:plain_text_regex]).to eq(["Regular expression is required for Plain Text parsers"])
      end

      it 'should require a valid regexp to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_regex => '('))
        expect(parser.valid?).to eq(false)
        expect(parser.errors[:plain_text_regex]).to eq(["Invalid regular expression"])
      end

      it 'should require a date mask to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_date_format => nil))
        expect(parser.valid?).to eq(false)
        expect(parser.errors[:plain_text_date_format]).to eq([ "Date format is required for Plain Text parsers"])
      end

      it 'should accept valids regexp to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_regex => '()', :plain_text_date_format => '%y'))
        expect(parser.valid?).to eq(true)
      end
    end
  end

  describe '#before_destroying' do
    it 'should prevent deletion of a parser if linked to a bank account' do
      user = FactoryGirl.create(:user)
      parser = FactoryGirl.create(:plain_text_parser)
      account = FactoryGirl.create(:bank_account, :statement_parser_id => parser.id, :user_id => user.id)
      expect {
        parser.destroy
      }.to_not change { StatementParsers::ParserBase.count }
    end
    it 'should allow deletion of a parser not linked to any bank account' do
      parser = FactoryGirl.create(:plain_text_parser)
      expect {
        parser.destroy
      }.to change { StatementParsers::ParserBase.count }.by(-1)
    end
  end

end
