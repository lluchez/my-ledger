require 'spec_helper'

def error_message(attribute, key)
  Locales::model_translation(:statement_record, attribute, key)
end

def csv_row_parsing_exception(row_index, attribute, key)
  Locales::exception_translation(:csv_row_parsing_exception, {message: error_message(attribute, key), row_index: row_index})
end

describe BankStatementsCsvParser do
  let(:parser) { BankStatementsCsvParser.new }

  describe '#parse_description' do
    it 'should raise an Exception when an invalid value is provided' do
      expect {
        parser.send(:parse_description, nil)
      }.to raise_error(StandardError, error_message(:description, :blank))
      expect {
        parser.send(:parse_description, '')
      }.to raise_error(StandardError, error_message(:description, :blank))
    end

    it 'should properly parse valid descriptions' do
      expect(parser.send(:parse_description, 'Transaction #1')).to eq("Transaction #1")
    end
  end

  describe '#parse_date' do
    it 'should raise an Exception when an invalid value is provided' do
      expect {
        parser.send(:parse_date, nil)
      }.to raise_error(StandardError, error_message(:date, :blank))

      expect {
        parser.send(:parse_date, '')
      }.to raise_error(StandardError, error_message(:date, :blank))

      expect {
        parser.send(:parse_date, 'abc')
      }.to raise_error(StandardError, error_message(:date, :invalid_format))

      expect {
        parser.send(:parse_date, '01-01-2017')
      }.to raise_error(StandardError, error_message(:date, :invalid_format))

      expect {
        parser.send(:parse_date, '2001/01-17')
      }.to raise_error(StandardError, error_message(:date, :invalid_format))

      expect {
        parser.send(:parse_date, '2001/13/40')
      }.to raise_error(StandardError, error_message(:date, :parsing_error))
    end

    it 'should properly parse valid dates' do
      expect(parser.send(:parse_date, '2017/01/01')).to eq(Date.new(2017,1,1))
      expect(parser.send(:parse_date, '2017/12/31')).to eq(Date.new(2017,12,31))
      expect(parser.send(:parse_date, '2017-12-31')).to eq(Date.new(2017,12,31))
    end
  end

  describe '#parse_amount' do
    it 'should raise an Exception when an invalid value is provided' do
      expect {
        parser.send(:parse_amount, nil)
      }.to raise_error(StandardError, error_message(:amount, :blank))

      expect {
        parser.send(:parse_amount, '')
      }.to raise_error(StandardError, error_message(:amount, :blank))

      expect {
        parser.send(:parse_amount, 'abc')
      }.to raise_error(StandardError, error_message(:amount, :invalid_format))

      expect {
        parser.send(:parse_amount, '123abc123')
      }.to raise_error(StandardError, error_message(:amount, :invalid_format))

      expect {
        parser.send(:parse_amount, '123.')
      }.to raise_error(StandardError, error_message(:amount, :invalid_format))
    end

    it 'should properly parse valid amounts' do
      expect(parser.send(:parse_amount, '55.55')).to eq(55.55)
      expect(parser.send(:parse_amount, '00055.55')).to eq(55.55)
      expect(parser.send(:parse_amount, '00 055.55')).to eq(55.55)
      expect(parser.send(:parse_amount, '+55.55')).to eq(55.55)
      expect(parser.send(:parse_amount, '-22')).to eq(-22.0)
      expect(parser.send(:parse_amount, '+1 000 000.55')).to eq(1000000.55)
    end
  end

  describe '#parse_line' do
    it 'should raise a CsvRowParsingException when the description field is incorrect' do
      line = 55
      attribute, err_key = "description", :blank
      expect(CsvRowParsingException).to receive(:new).with(error_message(attribute, err_key), attribute, line).and_call_original
      expect {
        parser.send(:parse_line, {
          "description" => "",
          "date" => "",
          "amount" => ""
        }, line)
      }.to raise_error(CsvRowParsingException, csv_row_parsing_exception(line, attribute, err_key))
    end

    it 'should raise a CsvRowParsingException when the date field is incorrect' do
      line = 2
      attribute, err_key = "date", :invalid_format
      expect(CsvRowParsingException).to receive(:new).with(error_message(attribute, err_key), attribute, line).and_call_original
      expect {
        parser.send(:parse_line, {
          "description" => "Test",
          "date" => "55",
          "amount" => ""
        }, line)
      }.to raise_error(CsvRowParsingException, csv_row_parsing_exception(line, attribute, err_key))
    end

    it 'should raise a CsvRowParsingException when the amount field is incorrect' do
      line = 22
      attribute, err_key = "amount", :blank
      expect(CsvRowParsingException).to receive(:new).with(error_message(attribute, err_key), attribute, line).and_call_original
      expect {
        parser.send(:parse_line, {
          "description" => "Test",
          "date" => "2018-01-05",
          "amount" => ""
        }, line)
      }.to raise_error(CsvRowParsingException, csv_row_parsing_exception(line, attribute, err_key))
    end

    it 'should return the correct hash when the row is correct' do
      expect(parser.send(:parse_line, {
        "description" => "Test",
        "date" => "2018-01-05",
        "amount" => "155.55"
      }, 1)).to eq({
        :description => "Test",
        :date => Date.new(2018,1,5),
        :amount => 155.55
      })
    end

    it 'should return the correct hash when the row is correct even if column names are capitalized' do
      expect(parser.send(:parse_line, {
        "Description" => "Test",
        "Date" => "2018-01-05",
        "Amount" => "155.55"
      }, 1)).to eq({
        :description => "Test",
        :date => Date.new(2018,1,5),
        :amount => 155.55
      })
    end
  end

  describe '#parse' do
    it 'should raise an exception when at least one line is not correct' do
      file = File.new(file_fixture('csv_bank_statements/statement_invalid.csv'))
      expected_errros = BANK_STATEMENT_CSV_FILE_INVALID_ROWS.map do |row|
        csv_row_parsing_exception(row[:row_index], row[:attribute], row[:err_key])
      end
      expect {
        parser.parse(file)
      }.to raise_error(CsvFileParsingException)
      begin
        parser.parse(file)
      rescue CsvFileParsingException => e
        expect(e.message).to eq(Locales::exception_translation(:csv_file_parsing_exception, {err_count: BANK_STATEMENT_CSV_FILE_INVALID_ROWS_COUNT}))
        expect(e.exceptions.map(&:message)).to eq(expected_errros)
      end
    end

    it 'should properly parse a valid CSV file' do
      file = File.new(file_fixture('csv_bank_statements/statement_valid.csv'))
      lines = parser.parse(file)
      expect(lines.class).to eq(Array)
      expect(lines.count).to eq(BANK_STATEMENT_CSV_FILE_VALID_ROWS_COUNT)
      expect(lines).to eq(BANK_STATEMENT_CSV_FILE_VALID_ROWS)
    end

    it 'should properly parse a valid CSV buffer' do
      lines = parser.parse(BANK_STATEMENT_CSV_VALID_TEXT)
      expect(lines.class).to eq(Array)
      expect(lines.count).to eq(BANK_STATEMENT_CSV_FILE_VALID_ROWS_COUNT)
      expect(lines).to eq(BANK_STATEMENT_CSV_FILE_VALID_ROWS)
    end
  end
end
