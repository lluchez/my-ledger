require 'spec_helper'

class LocalesWrapper
  include LocalesHelper
end

class LocalesController
  include LocalesHelper
end

describe LocalesHelper do
  let(:translator) { LocalesWrapper.new }
  let(:controller) { LocalesController.new }

  describe '#has_translation' do
    it 'should return false when the translation does not exist' do
      key = "key_path"
      expect(I18n).to receive(:exists?).with(key).and_return(false)
      expect(translator.has_translation?(key)).to eq(false)
    end

    it 'should return true when the translation exists' do
      key = "key_path"
      expect(I18n).to receive(:exists?).with(key).and_return(true)
      expect(translator.has_translation?(key)).to eq(true)
    end
  end

  describe '#get_translation' do
    it 'should raise an exception and raise a Rollbar when the translation does not exist' do
      key = "key_path"
      expect(I18n).to receive(:t).with(key, {:default => nil}).and_return(nil)
      expect(RollbarHelper).to receive(:error).once
      expect {
        translator.get_translation(key)
      }.to raise_error(StandardError, anything())
    end

    it 'should return true when the translation exists' do
      key = "key_path"
      expected_value = 'value'
      allow_any_instance_of(LocalesWrapper).to receive(:try_translation).with(key, anything()).and_return(expected_value)
      expect(translator.get_translation(key)).to eq(expected_value)
    end
  end

  describe '#controller_translation' do
    def translate(*args)
      controller.controller_translation(controller, *args)
    end

    it 'should return the controller translation if it exists' do
      expect(I18n).to receive(:t).once.with("controllers.locales_controller.created", {:default => nil, :name => "Test"}).and_return("Locales Test has successfully been created.")
      translation = translate(:created, {:name => "Test"})
      expect(translation).to eq("Locales Test has successfully been created.")
    end

    context 'controller translation does not exists' do
      it 'should return the default/generic controller translation if it exists' do
        expect(I18n).to receive(:t).once.with("controllers.locales_controller.created", {:default => nil, :name => "Test"}).and_return(nil)
        expect(I18n).to receive(:t).once.with("controllers.locales_controller.type", {:default => nil}).and_return("Locales")
        expect(I18n).to receive(:t).once.with("controllers.default.created", {:default => nil, :name => "Test", :type => "Locales"}).and_return("Locales Test was successfully created.")
        translation = translate(:created, {:name => "Test"})
        expect(translation).to eq("Locales Test was successfully created.")
      end

      it 'should raise an exception and raise a Rollbar when the controller translations do not exist as well as the `type` key' do
        expected_error = "Missing controller translation for key 'created' on LocalesController"
        expect(I18n).to receive(:t).once.with("controllers.locales_controller.created", {:default => nil, :name => "Test"}).and_return(nil)
        expect(I18n).to receive(:t).once.with("controllers.locales_controller.type", {:default => nil}).and_return(nil)

        expect(RollbarHelper).to receive(:error).once.with(expected_error)
        expect {
          translate(:created, {:name => "Test"})
        }.to raise_error(StandardError, expected_error)
      end

      it 'should raise an exception and raise a Rollbar when the controller and generic controller translations do not exist' do
        expected_error = "Missing controller translation for key 'created' on LocalesController"
        expect(I18n).to receive(:t).once.with("controllers.locales_controller.created", {:default => nil, :name => "Test"}).and_return(nil)
        expect(I18n).to receive(:t).once.with("controllers.locales_controller.type", {:default => nil}).and_return("Locales")
        expect(I18n).to receive(:t).once.with("controllers.default.created", {:default => nil, :name => "Test", :type => "Locales"}).and_return(nil)

        expect(RollbarHelper).to receive(:error).once.with(expected_error)
        expect {
          translate(:created, {:name => "Test"})
        }.to raise_error(StandardError, expected_error)
      end
    end
  end
end
