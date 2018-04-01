class BaseException < StandardError
  include LocalesHelper

  def i18n_message(params = {})
    exception_translation(self, params)
  end
end
