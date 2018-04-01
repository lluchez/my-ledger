class CsvFileParsingException < BaseException
  attr_reader :exceptions, :csv_file

  def initialize(exceptions, csv_file)
    super(i18n_message({:err_count => exceptions.count}))
    @exceptions = exceptions
    @csv_file   = csv_file
  end
end
