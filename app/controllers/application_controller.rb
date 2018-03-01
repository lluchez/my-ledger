class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound do |exception|
    not_found
  end

  def index
    if user_signed_in?
      redirect_to bank_accounts_path
    else
      redirect_to new_user_session_path, :flash => { :alert => I18n.t("general.login") }
    end
  end

  protected
  def not_found
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/app/views/errors/404", :layout => true, :status => :not_found }
      format.any  { head :not_found }
    end
  end

  def i18n_message(key, params = {})
    params[:default] = nil # to return `nil` if the text isn't found
    base_key = "controllers.#{self.class.name.underscore}"
    text = I18n.t("#{base_key}.#{key}", params)
    if text.blank?
      type = I18n.t("#{base_key}.type")
      if type.present?
        text = I18n.t("controllers.default.#{key}", params.merge(:type => type))
      end
    end

    RollbarHelper.warning("Missing controller translation for key '#{key} in #{self.class.name}") if text.blank?
    text
  end
end
