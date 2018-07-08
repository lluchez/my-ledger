require 'spec_helper'

class ViewsHelperWrapper
  include ViewsHelper
end

describe ViewsHelper do
  let(:helper) { ViewsHelperWrapper.new }

  describe '#yes_no' do
    it 'should return the correct transalation based on the given param' do
      expect(helper.yes_no(true)).to eq("Yes")
      expect(helper.yes_no("")).to eq("Yes")
      expect(helper.yes_no(0)).to eq("Yes")
      expect(helper.yes_no(false)).to eq("No")
      expect(helper.yes_no(nil)).to eq("No")
    end
  end
end
