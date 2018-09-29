require 'spec_helper'

describe StatementParsers::PlainTextParser do

  let(:parser) { FactoryBot.build(:plain_text_parser) }

  describe '#validate_specific_fields' do
    context 'PlainTextParser' do
      let(:attrs) { FactoryBot.attributes_for(:plain_text_parser) }

      it 'should require a regexp to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_regex => nil))
        expect(parser.valid?).to eq(false)
        expect_to_have_error(parser, :plain_text_regex, :blank)
      end

      it 'should require a valid regexp to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_regex => '('))
        expect(parser.valid?).to eq(false)
        expect_to_have_error(parser, :plain_text_regex, :invalid_regexp, :err_msg => "end pattern with unmatched parenthesis: /^($/")
      end

      it 'should require a date mask to parse statements' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_date_format => nil))
        expect(parser.valid?).to eq(false)
        expect_to_have_error(parser, :plain_text_date_format, :blank)
      end

      it 'should validate that all capturing groups are defined' do
        parser = StatementParsers::ParserBase.new(attrs.merge(:plain_text_regex => '()', :plain_text_date_format => '%y'))
        expect(parser.valid?).to eq(false)
        expect_to_have_error(parser, :plain_text_regex, :missing_group, :group_name => 'date')
        expect_to_have_error(parser, :plain_text_regex, :missing_group, :group_name => 'description')
        expect_to_have_error(parser, :plain_text_regex, :missing_group, :group_name => 'amount')
      end

      it 'should validate that all capturing groups are defined' do
        parser = StatementParsers::ParserBase.new(attrs)
        expect(parser.valid?).to eq(true)
      end
    end
  end

  describe '#parse_date' do
    context 'bad data' do
      it 'should return nil' do
        expect(parser.parse_date(nil)).to be_nil
        expect(parser.parse_date('')).to be_nil
        expect(parser.parse_date('abc')).to be_nil
        expect(parser.parse_date('2017/2017')).to be_nil
      end
    end

    context 'valid data' do
      it 'should properly parse and return the correct date' do
        expect(parser.parse_date('2017/01/02')).to eq(Date.new(2017,1,2))
        expect(parser.parse_date('2017-01-02')).to eq(Date.new(2017,1,2))
        expect(parser.parse_date('20170102')).to eq(Date.new(2017,1,2))
        expect(parser.parse_date('3rd Feb 2017')).to eq(Date.new(2017,2,3))
        # to be completed
      end
    end
  end

  describe '#parse_amount' do
    context 'bad data' do
      # to be completed
    end

    context 'valid data' do
      it 'properly parse' do
        expect(parser.parse_amount('1,234.56')).to eq(1234.56)
        expect(parser.parse_amount('-1,234.56')).to eq(-1234.56)
        expect(parser.parse_amount('1a2b3.456')).to eq(123.456)
        expect(parser.parse_amount('+1.99')).to eq(1.99)
      end
    end
  end

  describe '#parse_line' do
    let(:line_number) { 1 }
    let(:locales_prefix) { "custom_errors.plain_text_statement_parser" }

    context 'bad data' do
      it 'should require the line to match' do
        expect{
          parser.parse_line('abc', line_number)
        }.to raise_error(I18n.t("#{locales_prefix}.line_format", :line_number => line_number))
      end

      it 'should require all groups to be present' do
        expect{
          parser.parse_line('2017/01/01  1234.56', line_number)
        }.to raise_error(I18n.t("#{locales_prefix}.missing_groups", {:line_number => line_number, :missing_groups => 'description'}))
      end

      it 'should require the date to be valid' do
        date = '2017/99/99'
        expect{
          parser.parse_line("#{date} store 1234.56", line_number)
        }.to raise_error(I18n.t("#{locales_prefix}.date_format",  {:line_number => line_number, :date => date}))
      end
    end

    context 'good data' do
      it 'should properly parse' do
        attrs = parser.parse_line("2017/01/02 store 1234.56", line_number)
        expect(attrs).to be
        expect(attrs[:date]).to eq(Date.new(2017,1,2))
        expect(attrs[:amount]).to eq(1234.56)
        expect(attrs[:description]).to eq('store')
      end
    end
  end

  describe '#get_records_attributes_from_raw_text' do
    let(:parser) { FactoryBot.build(:chase_parser) }

    context 'empty data' do
      it 'should not return any attributes nether errors' do
        result = parser.get_records_attributes_from_raw_text("\n\n")
        expect(result[:attributes].present?).to be(false)
        expect(result[:errors].present?).to be(false)
      end
    end

    context 'with errors' do
      it 'should return errors when lines are incorrect' do
        lines = file_fixture('plain_text_statements/chase_statement_invalid.txt').read
        result = parser.get_records_attributes_from_raw_text(lines)
        expect(result[:attributes].count).to eq(1)
        expect(result[:errors].count).to be(3)
        expect(result[:errors]).to eq([
          "Unable to parse line 1",
          "Missing group(s) on line 3: description",
          "Couldn't parse the date '99/99' on line 4"
        ])
      end
    end

    context 'good data' do
      it 'should properly read all not-empty lines' do
        lines = file_fixture('plain_text_statements/chase_statement_valid.txt').read
        result = parser.get_records_attributes_from_raw_text(lines)

        expect(result[:errors].blank?).to be(true)
        expect(result[:attributes].count).to eq(5)
        expect(result[:attributes].map{ |a| a[:amount] }).to eq([17.85, 8.49, -8.49, 1361.59, 8.14].map(&:to_d))
        expect(result[:attributes].map{ |a| a[:description] }).to eq([
          'UBER *TRIP JJ7ZD 800-592-8996 CA',
          'AMAZON MKTPLACE PMTS AMZN.COM/BILL WA',
          'AMAZON MKTPLACE PMTS AMZN.COM/REFUND WA',
          'OLD NAVY US 5935 OAK PARK IL',
          'CHIPOTLE 0711 CHICAGO IL'
        ])
        expect(result[:attributes].map{ |a| a[:date].month }.uniq).to eq([12])
        expect(result[:attributes].map{ |a| a[:date].day }).to eq([1, 3, 4, 7, 8])
      end
    end
  end

end
