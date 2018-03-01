require 'spec_helper'

def expect_same_exceptions(e1, e2)
  expect(e1.message).to eq(e2.message)
  expect(e1.class).to eq(e2.class)
end

describe RollbarHelper do
  describe '#get_exception' do
    it 'should return a correct exception' do
      msg = 'Test'
      ex1 = StandardError.new(msg)
      (model = StatementRecord.new).valid?
      ex2 = ActiveRecord::RecordInvalid.new(model)
      expect_same_exceptions(RollbarHelper.send(:get_exception, nil, msg), Exception.new(msg))
      expect_same_exceptions(RollbarHelper.send(:get_exception, ex1, nil), ex1)
      expect_same_exceptions(RollbarHelper.send(:get_exception, ex1, msg), StandardError.new("#{msg}: #{ex1}"))
      expect_same_exceptions(RollbarHelper.send(:get_exception, ex2, msg), Exception.new("#{msg} (#{ex2.class.name}): #{ex2}"))
    end
  end

  describe '#warning' do
    context 'without fingerprint' do
      it 'should call Rollbar.warning without providing a fingerprint' do
        exception = StandardError.new("Test")
        expect(RollbarHelper).to receive(:get_exception).once.and_return(exception)
        expect(Rails.logger).to receive(:warn).once.with(exception)
        expect(Rollbar).to receive(:warning).once.with(exception)
        RollbarHelper.warning(nil, e: exception)
      end
    end
    context 'with fingerprint' do
      it 'should call Rollbar.warning by providing a fingerprint' do
        exception = StandardError.new("Test")
        fingerprint = :test_fingerprint
        expect(RollbarHelper).to receive(:get_exception).once.and_return(exception)
        expect(Rails.logger).to receive(:warn).once.with(exception)
        expect(Rollbar).to receive(:scope).once.with(:fingerprint => fingerprint).and_call_original
        expect_any_instance_of(Rollbar::Notifier).to receive(:warn).once.with(exception)
        RollbarHelper.warning(nil, e: exception, fingerprint: fingerprint)
      end
    end
  end

  describe '#error' do
    context 'without fingerprint' do
      it 'should call Rollbar.error without providing a fingerprint' do
        exception = StandardError.new("Test")
        expect(RollbarHelper).to receive(:get_exception).once.and_return(exception)
        expect(Rails.logger).to receive(:error).once.with(exception)
        expect(Rollbar).to receive(:error).once.with(exception)
        RollbarHelper.error(nil, e: exception)
      end
    end
    context 'with fingerprint' do
      it 'should call Rollbar.error by providing a fingerprint' do
        exception = StandardError.new("Test")
        fingerprint = :test_fingerprint
        expect(RollbarHelper).to receive(:get_exception).once.and_return(exception)
        expect(Rails.logger).to receive(:error).once.with(exception)
        expect(Rollbar).to receive(:scope).once.with(:fingerprint => fingerprint).and_call_original
        expect_any_instance_of(Rollbar::Notifier).to receive(:error).once.with(exception)
        RollbarHelper.error(nil, e: exception, fingerprint: fingerprint)
      end
    end
  end
end
