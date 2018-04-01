require 'spec_helper'

describe ApplicationRecord do

  describe '#i18n_message' do
    it 'should call I18n.t with the correct key' do
      full_key = "activerecord.errors.models.statement_record.attributes.attr1.key1"
      expect(I18n).to receive(:t).once.with(full_key, {:default => nil}).and_return("Custom error for attr1")
      resource = StatementRecord.new
      expect(resource.i18n_message(:attr1, :key1)).to eq("Custom error for attr1")
    end
  end

end
