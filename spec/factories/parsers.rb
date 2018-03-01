FactoryGirl.define do
  factory :base_parser, :class => StatementParsers::ParserBase do
    factory :plain_text_parser, :class => StatementParsers::PlainTextParser do
      type 'PlainTextParser'
      sequence(:name) { |n| "Plain Text Parser #{n}" }
      plain_text_regex '(?<date>\d+/\d+) +(?<description>.*?) +(?<amount>[+\-]?[\d\.\,]+)'
      plain_text_date_format '%m/%-d'

      factory :discover_parser do
        name 'Discover Credit Card Parser'
        plain_text_regex '(?<date>\w+ \d+)(?:\s+\w+ \d+\s+)(?<description>.*?)(?: +\$)? +(?<amount>[+\-]?[\d\.\,]+)'
        plain_text_date_format '%b %-d'
      end

      factory :chase_parser do
        name 'Chase Credit Card Parser'
        plain_text_regex '(?<date>\d+/\d+) +(?<description>.*?) +(?<amount>[+\-]?[\d\.\,]+)'
        plain_text_date_format '%m/%-d'
      end
    end
  end
end
