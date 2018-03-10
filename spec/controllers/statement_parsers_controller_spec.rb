require 'spec_helper'

RSpec.describe StatementParsersController, type: :controller do
  render_views

  let(:param_key) {:statement_parsers_parser_base }
  let(:user) { double('user') }

  describe "GET #index" do
    let!(:parser) { FactoryBot.create(:chase_parser) }

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

    it "should return a success JSON response" do
      sign_in(user)

      get :index, params: {}, format: :json
      expect(response).to be_success

      data = JSON.parse(response.body)
      expect(data.count).to eq(1)
      ids = data.map{ |o| o["id"] }
      expect(ids).to include(parser.id)
      assert_json_statement_parser(data.first, parser)
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
    let(:parser) { FactoryBot.create(:plain_text_parser) }

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

    it "should return a success JSON response" do
      sign_in(user)

      get :show, params: {:id => parser.id}, format: :json
      expect(response).to be_success

      assert_json_statement_parser(hash_from_json_body, parser)
    end
  end

  describe "POST #create" do
    let(:parser_attrs) { FactoryBot.attributes_for(:plain_text_parser) }

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

    it "should create the parser and return a success response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => parser_attrs}
      }.to change { StatementParsers::ParserBase.count }.by(1)
      expect(response).to redirect_to(statement_parsers_url)
      # expect(flash[:notice]).to be_present
    end

    it "should create the parser and return a success JSON response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => parser_attrs}, format: :json
        expect(response).to be_success
      }.to change { StatementParsers::ParserBase.count }.by(1)

      assert_json_statement_parser(hash_from_json_body, assigns[:parser])
    end
  end

  describe "PUT #update" do
    let(:parser) { FactoryBot.create(:plain_text_parser) }

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
      new_name = 'Test Parser'

      expect {
        put :update, params: {:id => parser.id, param_key => {:name => new_name}}
      }.to change { parser.reload.name }.to(new_name)
      expect(response).to redirect_to(statement_parsers_url)
      expect(flash[:notice]).to be_present
    end

    it "update the parser and returns a success response" do
      sign_in(user)
      new_name = 'Test Parser'

      expect {
        put :update, params: {:id => parser.id, param_key => {:name => new_name}}, format: :json
        expect(response).to be_success
      }.to change { parser.reload.name }.to(new_name)

      json = assert_json_statement_parser(hash_from_json_body, parser.reload)
      expect(json[:name]).to eq(new_name)
    end
  end

  describe "DELETE #destroy" do
    let!(:parser) { FactoryBot.create(:plain_text_parser) }

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

      bank_account = FactoryBot.create(:bank_account, :statement_parser_id => parser.id)
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

    it "should delete the existing parser of that user and return an empty JSON response" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => parser.id}, format: :json
        expect(response).to be_success
      }.to change { StatementParsers::ParserBase.count }.by(-1)

      expect(response.body).to be_blank
    end
  end

end
