class ApplicationRecord < ActiveRecord::Base
  include LocalesHelper

  self.abstract_class = true

  def i18n_message(attribute, err_key, params = {})
    model_translation(self, attribute, err_key, params)
  end

  def self.hash_to_collection(hash)
    array = []
    hash.each do |key, value|
      array << [value, key]
    end
    array
  end
end
