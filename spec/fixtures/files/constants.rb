
# BankStatement CSV Files
# -----------------------

def to_row(row)
  "\"#{row[:description]}\",\"#{row[:date]}\",\"#{row[:amount]}\""
end

# Valid CSV File
BANK_STATEMENT_CSV_FILE_VALID_ROWS = [
  {:description => "transaction 1", :date => Date.new(2017,12,31), :amount => 1369.99},
  {:description => "transaction 2", :date => Date.new(2018,1,1),   :amount => 1169.9},
  {:description => "transaction 3", :date => Date.new(2018,4,28),  :amount => -1199.89}
]
BANK_STATEMENT_CSV_FILE_VALID_ROWS_COUNT = BANK_STATEMENT_CSV_FILE_VALID_ROWS.count

BANK_STATEMENT_CSV_HEADER = %w(description date amount).map{ |n| "\"#{n}\"" }.join(",")
BANK_STATEMENT_CSV_VALID_TEXT = "#{BANK_STATEMENT_CSV_HEADER}\n#{BANK_STATEMENT_CSV_FILE_VALID_ROWS.map{ |r| to_row(r) }.join("\n")}"

# Invalid CSV File
BANK_STATEMENT_CSV_FILE_INVALID_ROWS = [
  {:row_index => 4, :attribute => :description, :err_key => :blank},
  {:row_index => 5, :attribute => :date,        :err_key => :parsing_error},
  {:row_index => 6, :attribute => :amount,      :err_key => :invalid_format}
]
BANK_STATEMENT_CSV_FILE_INVALID_ROWS_COUNT = BANK_STATEMENT_CSV_FILE_INVALID_ROWS.count
