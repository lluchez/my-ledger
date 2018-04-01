require 'spec_helper'

describe ExceptionsHelper do
  describe '#create' do
    it 'should create an exception' do
      klass = StandardError
      message = "Test"
      ex = ExceptionsHelper.create(klass, [message])
      expect(ex.class).to eq(klass)
      expect(ex.message).to eq(message)
    end
  end

  describe '#set_backtrace' do
    it 'should replace the trace if a second exception is provided' do
      e2 = nil
      begin; 1 / 0; rescue StandardError => e; e2 = e; end # generate an exception

      e1 = StandardError.new("Test")
      expect(e1.backtrace).to eq(nil)

      expect(ExceptionsHelper.set_backtrace(e1, e2)).to eq(e1)
      expect(e1.backtrace).to eq(e2.backtrace)
    end
  end
end
