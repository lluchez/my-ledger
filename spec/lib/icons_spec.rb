require 'spec_helper'

describe Icons do
  describe '#add_or_edit' do
    it 'should return the correct icon based on the given param' do
      expect(Icons::add_or_edit(true)).to eq(Icons::EDIT)
      expect(Icons::add_or_edit(false)).to eq(Icons::ADD)
    end
  end
end
