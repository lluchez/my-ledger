require 'test_helper'

class StatementParsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @statement_parser = statement_parsers(:one)
  end

  test "should get index" do
    get statement_parsers_url
    assert_response :success
  end

  test "should get new" do
    get new_statement_parser_url
    assert_response :success
  end

  test "should create statement_parser" do
    assert_difference('StatementParser.count') do
      post statement_parsers_url, params: { statement_parser: { description: @statement_parser.description, name: @statement_parser.name, plain_text_date_format: @statement_parser.plain_text_date_format, plain_text_regex: @statement_parser.plain_text_regex, type: @statement_parser.type } }
    end

    assert_redirected_to statement_parser_url(StatementParser.last)
  end

  test "should show statement_parser" do
    get statement_parser_url(@statement_parser)
    assert_response :success
  end

  test "should get edit" do
    get edit_statement_parser_url(@statement_parser)
    assert_response :success
  end

  test "should update statement_parser" do
    patch statement_parser_url(@statement_parser), params: { statement_parser: { description: @statement_parser.description, name: @statement_parser.name, plain_text_date_format: @statement_parser.plain_text_date_format, plain_text_regex: @statement_parser.plain_text_regex, type: @statement_parser.type } }
    assert_redirected_to statement_parser_url(@statement_parser)
  end

  test "should destroy statement_parser" do
    assert_difference('StatementParser.count', -1) do
      delete statement_parser_url(@statement_parser)
    end

    assert_redirected_to statement_parsers_url
  end
end
