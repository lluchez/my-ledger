require 'spec_helper'

describe Audit do

  describe '#date_formatted' do
    it 'should properly format the date' do
      audit = Audit.new(:created_at => DateTime.new(2017,1,2, 19,13,2))
      expect(audit.date_formatted).to eq("2017-01-02 19:13:02")
    end
  end

  describe '#action_formatted' do
    it 'should properly format the action' do
      {
        "update" => "Update",
        "create" => "Create"
      }.each do |value, expected_value|
        audit = Audit.new(:action => value)
        expect(audit.action_formatted).to eq(expected_value)
      end
    end
  end

  describe '#model_formatted' do
    it 'should properly format the model' do
      {
        "StatementRecord" => "Transaction",
        "StatementParsers/BaseParser" => "Parser",
        "BankAccount" => "Bank Account"
      }.each do |value, expected_value|
        audit = Audit.new(:auditable_type => value)
        expect(audit.model_formatted).to eq(expected_value)
      end
    end
  end

  describe '#auditable_url' do
    it 'should generate the correct link' do
      id = 55
      {
        "StatementRecord" => "/statement_records/#{id}",
        "StatementParsers/BaseParser" => "/statement_parsers/#{id}",
        "BankAccount" => "/bank_accounts/#{id}",
        "Unknown" => nil
      }.each do |type, expected_value|
        audit = Audit.new(:auditable_type => type, :auditable_id => id)
        if expected_value.nil?
          expect(audit.auditable_url).to be_nil
        else
          expect(audit.auditable_url).to end_with(expected_value)
        end
      end
    end
  end

  describe 'self' do
    describe 'format_column' do
      it 'should properly format the column name' do
        expect(Audit.format_column('amount')).to eq("Amount")
        expect(Audit.format_column('total_amount')).to eq("Total amount")
      end
    end

    describe 'format_value' do
      it 'should properly format the value' do
        expect(Audit.format_value(nil)).to eq("[NULL]")
        expect(Audit.format_value('')).to eq("\"\"")
        expect(Audit.format_value("test")).to eq("test")
        expect(Audit.format_value(3)).to eq("3")
        expect(Audit.format_value(3.14)).to eq("3.14")
        expect(Audit.format_value(true)).to eq("true")
        expect(Audit.format_value(false)).to eq("false")
      end
    end
  end

end