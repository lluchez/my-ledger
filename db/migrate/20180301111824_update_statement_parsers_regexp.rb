class UpdateStatementParsersRegexp < ActiveRecord::Migration[5.0]
  def get_regexps
    [
      { # Chase
        :old => '(?<date>d+/d+)? +(?<description>.*?)(?: +$)? +(?<amount>-?d+(?:.d+)?)',
        :new => '(?<date>\d+/\d+) +(?<description>.*?) +\$?(?<amount>[+\-]?[\d\.\,]+)'
      },
      { # Discover
        :old => '(?<date>[A-Z][a-z]+ d+)(?: +[A-Z][a-z]+ +d+ +)(?<description>.*?)(?: +$)? +(?<amount>-?d+(?:.d+)?)',
        :new => '(?<date>\w+ \d+)(?:\s+\w+ \d+\s+)(?<description>.*?)(?: +\$)? +(?<amount>[+\-]?[\d\.\,]+)'
      }
    ]
  end

  def up
    get_regexps.each do |regexp_hash|
      StatementParsers::PlainTextParser.where(:plain_text_regex => regexp_hash[:old]).update_all(:plain_text_regex => regexp_hash[:new])
    end
  end

  def down
    get_regexps.each do |regexp_hash|
      StatementParsers::PlainTextParser.where(:plain_text_regex => regexp_hash[:new]).update_all(:plain_text_regex => regexp_hash[:old])
    end
  end
end
