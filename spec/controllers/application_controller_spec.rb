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

  describe "#add_flash_message" do
    let(:custom_message) { "This is a custom message" }

    it "should return the message if no other message is set" do
      controller.flash[:alert] = nil
      expect(controller.send(:add_flash_message, :alert, custom_message)).to eq([custom_message])
    end

    it "should return the message if there is another message" do
      existing_message = "Existing message"
      controller.flash[:alert] = existing_message
      expect(controller.send(:add_flash_message, :alert, custom_message)).to eq([existing_message, custom_message])
    end

    it "should return the message if there are other messages" do
      existing_message1 = "Message 1"
      existing_message2 = "Message 2"
      controller.flash[:alert] = [existing_message1, existing_message2]
      expect(controller.send(:add_flash_message, :alert, custom_message)).to eq([existing_message1, existing_message2, custom_message])
    end
  end

end
