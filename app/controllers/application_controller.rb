class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    # render plain: user_signed_in? ? %Q(Hello #{current_user.name}) : "Not logged yet..."
    if user_signed_in?
      redirect_to bank_accounts_path
    else
      redirect_to new_user_session_path, :flash => { :alert => "Please log-in first..." }
    end
  end

  protected
  def not_found
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/app/views/errors/404", :layout => true, :status => :not_found }
      format.any  { head :not_found }
    end
  end
end
