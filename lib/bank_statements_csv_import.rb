class BankStatementsCsvImport
  include LocalesHelper

  def initialize(user = nil)
    @user = user
  end

  def import(bank_statement, csv_file, remove_existing_records)
    records_data = BankStatementsCsvParser.new(@user).parse(csv_file)
    begin
      ActiveRecord::Base.transaction do
        delete_existing_records(bank_statement) if remove_existing_records
        records_data.map do |attributes|
          import_record(bank_statement, attributes)
        end
      end
    rescue StandardError => e
      msg = get_translation("lib.bank_statements_csv_import.unable_to_save")
      RollbarHelper.error(msg, :e => e)
      raise ExceptionsHelper.create(StandardError, [msg], e)
    end
  end

private

  def delete_existing_records(bank_statement)
    StatementRecord.where(:statement_id => bank_statement.id).destroy_all
    bank_statement.update_attributes(:total_amount => 0)
  end

  def import_record(bank_statement, attributes)
    attrs = attributes.merge({
      :user_id => bank_statement.user_id,
      :statement_id => bank_statement.id
    })
    StatementRecord.create!(attrs)
  end
end
