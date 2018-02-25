require 'spec_helper'

RSpec.describe StatementParsersController, type: :controller do
  render_views

  let(:param_key) {:statement_parsers_parser_base }
  let(:user) { double('user') }

  describe "GET #index" do
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

  describe "GET #new" do
    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      get :new, params: {}
      expect_to_redirect_log_in_page
    end

    it "should return a success response" do
      sign_in(user)

      get :new, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #show/#edit" do
    let(:parser) { FactoryGirl.create(:plain_text_parser) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      [:show, :edit].each do |method|
        get method, params: {:id => parser.id}
        expect_to_redirect_log_in_page
      end
    end

    it "should return a 404 response when the parser does not exist" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => 999999}
        expect_to_render_404
      end
    end

    it "should return a success response" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => parser.id}
        expect(response).to be_success
      end
    end
  end

  describe "POST #create" do
    let(:parser_attrs) { FactoryGirl.attributes_for(:plain_text_parser) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      post :create, params: {param_key => parser_attrs}
      expect_to_redirect_log_in_page
    end

    it "should not create parser without params" do
      sign_in(user)

      expect {
        post :create, params: {}
      }.to_not change { StatementParsers::ParserBase.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create parser with invalid params" do
      sign_in(user)

      expect {
        post :create, params: {param_key => {:name => 'Test Parser'}}
      }.to_not change { StatementParsers::ParserBase.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should create the parser and returns a success response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => parser_attrs}
      }.to change { StatementParsers::ParserBase.count }.by(1)
      expect(response).to redirect_to(statement_parsers_url)
      # expect(flash[:notice]).to be_present
    end
  end

  describe "PUT #update" do
    let(:parser) { FactoryGirl.create(:plain_text_parser) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      put :update, params: {:id => parser.id, param_key => {:name => 'New Name'}}
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the parser does not exist" do
      sign_in(user)

      put :update, params: {:id => 999999}
      expect_to_render_404
    end

    it "should not update parser without params" do
      sign_in(user)

      expect {
        put :update, params: {:id => parser.id}
      }.to_not change { parser.reload }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "should not update the parser with only invalid params but returns a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => parser.id, param_key => {:invalid => 'Test'}}
      }.to_not change { parser.reload }
      expect(response).to redirect_to(statement_parsers_url)
      expect(flash[:notice]).to be_present
    end

    it "update the parser and returns a success response" do
      sign_in(user)

      expect {
        put :update, params: {:id => parser.id, param_key => {:name => 'Test Parser'}}
      }.to change { parser.reload.name }.to('Test Parser')
      expect(response).to redirect_to(statement_parsers_url)
      expect(flash[:notice]).to be_present
    end
  end

  describe "DELETE #destroy" do
    let!(:parser) { FactoryGirl.create(:plain_text_parser) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      expect {
        delete :destroy, params: {:id => parser.id}
      }.to_not change { StatementParsers::ParserBase.count }
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the parser does not exist" do
      sign_in(user)

      delete :destroy, params: {:id => 999999}
      expect {
        expect_to_render_404
      }.to_not change { StatementParsers::ParserBase.count }
    end

    it "should not delete a used parser" do
      sign_in(user)

      bank_account = FactoryGirl.create(:bank_account, :statement_parser_id => parser.id)
      expect {
        delete :destroy, params: {:id => parser.id}
      }.to_not change { StatementParsers::ParserBase.count }
      expect(response).to redirect_to(statement_parser_url(parser))
      # expect(flash[:error]).to be_present
    end

    it "should delete existing and unused parser" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => parser.id}
      }.to change { StatementParsers::ParserBase.count }.by(-1)
      expect(response).to redirect_to(statement_parsers_url)
      expect(flash[:notice]).to be_present
    end
  end

end
