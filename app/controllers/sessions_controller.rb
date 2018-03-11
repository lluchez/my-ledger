class SessionsController < Devise::SessionsController

  def new
    add_flash_message(:alert, I18n.t("general.connection_not_secure")) unless request.ssl?
    super
  end

end
