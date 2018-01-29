require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do

  let(:user) { double('user') }

  describe "GET #index" do
    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      get :index
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end

    it "should return a success response" do
      sign_in(user)

      get :index
      expect(response).to redirect_to(bank_accounts_path)
    end
  end

end
