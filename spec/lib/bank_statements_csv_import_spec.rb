require 'spec_helper'

describe BankStatementsCsvImport do
  let(:bank_statement) { FactoryBot.create(:bank_statement) }
  let(:importer) { BankStatementsCsvImport.new }
  let(:valid_file) { File.new(file_fixture('csv_bank_statements/statement_valid.csv')) }
  let(:invalid_file) { File.new(file_fixture('csv_bank_statements/statement_invalid.csv')) }

  describe '#import' do
    before(:each) {
      previous_record = FactoryBot.create(:statement_record, :statement => bank_statement)
    }

    it 'should not update the statement or its record when an invalid CSV file is provided' do
      expect {
        expect {
          importer.import(bank_statement, invalid_file, true)
        }.to raise_error(CsvFileParsingException)
      }.to_not change{ bank_statement.reload.records.count }

      expect {
        expect {
          importer.import(bank_statement, invalid_file, false)
        }.to raise_error(CsvFileParsingException)
      }.to_not change{ bank_statement.reload.records.count }
    end

    it 'should raise a Rollbar and return a generic error message if unable to save the records' do
      allow_any_instance_of(StatementRecord).to receive(:save!).and_raise("Unexpected error")
      err_message = Locales::get_translation("lib.bank_statements_csv_import.unable_to_save")
      expect(RollbarHelper).to receive(:error).once.with(err_message, {:e => anything()})

      expect {
        expect {
          importer.import(bank_statement, valid_file, true)
        }.to raise_error(StandardError, err_message)
      }.to_not change{ bank_statement.reload.records.count }
    end

    it 'should import valid CSV files' do
      expect {
        importer.import(bank_statement, valid_file, true)
      }.to change{ bank_statement.reload.records.count }.to(BANK_STATEMENT_CSV_FILE_VALID_ROWS_COUNT)

      expect {
        importer.import(bank_statement, valid_file, false)
      }.to change{ bank_statement.reload.records.count }.by(BANK_STATEMENT_CSV_FILE_VALID_ROWS_COUNT)
    end
  end
end
