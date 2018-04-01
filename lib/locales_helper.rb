module LocalesHelper

  def has_translation?(key)
    I18n.exists?(key)
  end

  def try_translation(key, params = {})
    params[:default] = nil # to return `nil` if the text isn't found
    I18n.t(key, params)
  end

  def get_translation(key, params = {}, type = nil)
    translation = try_translation(key, params)
    if translation.nil?
      on_missing_translation(key, type)
    end
    translation
  end

  def on_missing_translation(key, type = nil)
    type = " #{type}" if type.present?
    message = "Missing#{type} translation for key '#{key}'"
    message = "#{message} on #{self.class.name}"

    RollbarHelper.error(message)
    unless Rails.env.production?
      # also raise an exception in dev/test to easily catch it
      raise StandardError.new(message)
    end
    nil
  end

  def exception_translation(resource_or_symbol, params = {})
    get_translation("lib.exceptions.#{key_from_resource_or_symbol(resource_or_symbol)}", params, :exception)
  end

  def model_translation(resource_or_symbol, attribute, err_key, params = {})
    key = "activerecord.errors.models.#{key_from_resource_or_symbol(resource_or_symbol)}.attributes.#{attribute.to_s}.#{err_key.to_s}"
    get_translation(key, params, :model)
  end

  def controller_translation(resource_or_symbol, key, params = {})
    base_key = "controllers"
    controller_key = "#{base_key}.#{key_from_resource_or_symbol(resource_or_symbol)}"

    text = try_translation("#{controller_key}.#{key}", params)
    if text.nil?
      type = try_translation("#{controller_key}.type")
      if type.present?
        text = try_translation("#{base_key}.default.#{key}", params.merge(:type => type))
      end
    end

    if text.nil?
      on_missing_translation(key, :controller)
    end
    text
  end

private

  def key_from_resource_or_symbol(resource_or_symbol)
    classname_from_resource_or_symbol(resource_or_symbol).underscore
  end

  def classname_from_resource_or_symbol(resource_or_symbol)
    resource_is_symbol?(resource_or_symbol) ? resource_or_symbol.to_s : resource_or_symbol.class.name
  end

  def resource_is_symbol?(resource_or_symbol)
    resource_or_symbol.class.in?([Symbol, String])
  end
end


class Locales
  class << self
    include LocalesHelper
  end
end
