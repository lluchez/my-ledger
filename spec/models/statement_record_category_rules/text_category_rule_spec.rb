require 'spec_helper'

describe StatementRecordCategoryRules::TextCategoryRule do

  describe '#matches?' do
    it 'should return false when the pattern does not match the provided text' do
      expect(described_class.new(:pattern => 'FOO', :case_sensitive => true).matches?('BAR')).to eq(false)
      expect(described_class.new(:pattern => 'JEWEL', :case_sensitive => true).matches?('Jewel')).to eq(false)
    end
    it 'should return true when the pattern matches the provided text' do
      expect(described_class.new(:pattern => 'JEWEL', :case_sensitive => false).matches?('Jewel')).to eq(true)
      expect(described_class.new(:pattern => 'JEWEL', :case_sensitive => false).matches?('text jewel text')).to eq(true)
      expect(described_class.new(:pattern => 'JEWEL', :case_sensitive => true).matches?('text JEWEL text')).to eq(true)
    end
  end

end
