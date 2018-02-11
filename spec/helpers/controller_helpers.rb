# code from : https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
module ControllerHelpers

  def sign_in(user = double('user'))
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end

  def expect_to_redirect_log_in_page
    expect(response).to redirect_to(new_user_session_path)
  end

  def expect_to_render_404
    expect(response.status).to eq(404)
    expect(response).to render_template(:file => "#{Rails.root}/app/views/errors/404.html.erb")
  end
end
