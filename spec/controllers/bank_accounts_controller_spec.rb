require 'spec_helper'

RSpec.describe BankAccountsController, type: :controller do
  render_views

  let(:param_key) {:bank_account }
  let(:user) { FactoryGirl.create(:user) }

  describe "GET #index" do
    let!(:bank_account) { FactoryGirl.create(:bank_account, :user_id => user.id) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      get :index, params: {}
      expect_to_redirect_log_in_page
    end

    it "should return a success response" do
      sign_in(user)

      get :index, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #show/#edit" do
    let(:owner) { FactoryGirl.create(:user) }
    let(:bank_account) { FactoryGirl.create(:bank_account, :user_id => owner.id) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      [:show, :edit].each do |method|
        get method, params: {:id => bank_account.id}
        expect_to_redirect_log_in_page
      end
    end

    it "should return a 404 response when the bank account does not exist" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => 999999}
        expect_to_render_404
      end
    end

    it "should return a 404 response when the bank account does not belong to the current user" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => bank_account.id}
        expect_to_render_404
      end
    end

    it "should return a success response" do
      sign_in(owner)

      [:show, :edit].each do |method|
        get method, params: {:id => bank_account.id}
        expect(response).to be_success
      end
    end
  end

  describe "POST #create" do
    let(:bank_account_attrs) do
      attrs = FactoryGirl.attributes_for(:bank_account)
      attrs.except(:parser).merge(:statement_parser_id => attrs[:parser].id)
    end

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      post :create, params: {param_key => bank_account_attrs}
      expect_to_redirect_log_in_page
    end

    it "should not create bank account without params" do
      sign_in(user)

      expect {
        post :create, params: {}
      }.to_not change { BankAccount.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create bank account with invalid params" do
      sign_in(user)

      expect {
        post :create, params: {param_key => {:name => 'Test Account'}}
      }.to_not change { BankAccount.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should create the bank account and returns a success response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => bank_account_attrs}
      }.to change { user.bank_accounts.count }.by(1)
      expect(response).to redirect_to(bank_account_url(assigns[:bank_account]))
      # expect(flash[:notice]).to be_present
    end
  end

  describe "PUT #update" do
    let(:other_bank_account) { FactoryGirl.create(:bank_account) }
    let(:my_bank_account) { FactoryGirl.create(:bank_account, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      put :update, params: {:id => my_bank_account.id, param_key => {:name => 'New Name'}}
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the bank account does not exist" do
      sign_in(user)

      put :update, params: {:id => 999999}
      expect_to_render_404
    end

    it "should not update bank account without params" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_bank_account.id}
      }.to_not change { my_bank_account.reload }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "should not update the bank account with only invalid params but returns a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_bank_account.id, param_key => {:invalid => 'Test'}}
      }.to_not change { my_bank_account.reload }
      expect(response).to redirect_to(bank_account_url(my_bank_account))
      expect(flash[:notice]).to be_present
    end

    it "should return a 404 response when the bank account does not exist" do
      sign_in(user)

      expect {
        put :update, params: {:id => other_bank_account.id, param_key => {:name => 'New Name'}}
      }.to_not change { other_bank_account.reload.name }
      expect_to_render_404
    end

    it "update the bank account and returns a success response" do
      sign_in(user)
      new_name = 'New Name'

      expect {
        put :update, params: {:id => my_bank_account.id, param_key => {:name => new_name}}
      }.to change { my_bank_account.reload.name }.to(new_name)
      expect(response).to redirect_to(bank_account_url(my_bank_account))
      expect(flash[:notice]).to be_present
    end
  end

  describe "DELETE #destroy" do
    let!(:other_bank_account) { FactoryGirl.create(:bank_account) }
    let!(:my_bank_account) { FactoryGirl.create(:bank_account, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      expect {
        delete :destroy, params: {:id => my_bank_account.id}
      }.to_not change { BankAccount.count }
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the bank account does not exist" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => 999999}
      }.to_not change { BankAccount.count }
      expect_to_render_404
    end

    it "should return a 404 response when trying to delete someone else's account" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => other_bank_account.id}
      }.to_not change { BankAccount.count }
      expect_to_render_404
    end

    it "should gracefully fail if the account cannot be removed" do
      sign_in(user)
      allow_any_instance_of(BankAccount).to receive(:destroy).and_return false

      expect {
        delete :destroy, params: {:id => my_bank_account.id}
      }.to_not change { BankAccount.count }
      expect(response).to redirect_to(bank_accounts_url)
      # expect(flash[:error]).to be_present
    end

    it "should delete the bank account of that user" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_bank_account.id}
      }.to change { BankAccount.count }.by(-1)
      expect(response).to redirect_to(bank_accounts_url)
      expect(flash[:notice]).to be_present
    end
  end

end
