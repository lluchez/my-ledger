def get_error_message(model, attribute, key, params = {})
  I18n.t("activerecord.errors.models.#{model.class.name.underscore}.attributes.#{attribute}.#{key.to_s}", params)
end

def expect_to_have_error(model, attribute, key, params = {})
  expect(model.errors[attribute]).to include(get_error_message(model, attribute, key, params))
end
