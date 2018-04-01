class CsvRowParsingException < BaseException
  attr_reader :attribute, :row_index

  def initialize(message, attribute, row_index)
    super(i18n_message({:message => message, :row_index => row_index}))
    @attribute = attribute
    @row_index = row_index
  end
end
