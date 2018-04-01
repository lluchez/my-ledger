class ApplicationRecord < ActiveRecord::Base
  include LocalesHelper

  self.abstract_class = true

  def i18n_message(attribute, err_key, params = {})
    model_translation(self, attribute, err_key, params)
  end
end
