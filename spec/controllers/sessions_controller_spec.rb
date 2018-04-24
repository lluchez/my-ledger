require 'spec_helper'

RSpec.describe SessionsController, type: :controller do
  render_views

  context "User is not signed in" do
    before(:each) do
      sign_in(nil)
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    describe "GET #index" do
      context "when not using a secure connection" do
        it "should show an alert message" do
          get :new
          expect(response).to be_successful
          expect(response.body).to include(I18n.t("general.connection_not_secure"))
        end
      end
    end
  end

end
