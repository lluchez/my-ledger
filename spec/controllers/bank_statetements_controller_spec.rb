require 'spec_helper'

RSpec.describe BankStatementsController, type: :controller do
  render_views

  let(:param_key) {:bank_statement }
  let(:user) { FactoryBot.create(:user) }

  describe "GET #index" do
    let!(:bank_statement) { FactoryBot.create(:bank_statement, :user_id => user.id) }
    let!(:other_statement) { FactoryBot.create(:bank_statement) }

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
      expect(ids).to include(bank_statement.id)
      expect(ids).to_not include(other_statement.id)
      assert_json_bank_statement(data.first, bank_statement)
      expect(data.first["bank_account_name"]).to eq(bank_statement.bank_account.name)
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
    let(:owner) { FactoryBot.create(:user) }
    let(:bank_statement) { FactoryBot.create(:bank_statement, :user_id => owner.id) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      [:show, :edit].each do |method|
        get method, params: {:id => bank_statement.id}
        expect_to_redirect_log_in_page
      end
    end

    it "should return a 404 response when the bank statement does not exist" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => 999999}
        expect_to_render_404
      end
    end

    it "should return a 404 response when the bank statement does not belong to the current user" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => bank_statement.id}
        expect_to_render_404
      end
    end

    it "should return a success response" do
      sign_in(owner)

      [:show, :edit].each do |method|
        get method, params: {:id => bank_statement.id}
        expect(response).to be_success
      end
    end

    it "should return a success JSON response" do
      sign_in(owner)

      get :show, params: {:id => bank_statement.id}, format: :json
      expect(response).to be_success

      assert_json_bank_statement(hash_from_json_body, bank_statement)
    end
  end

  describe "POST #create" do
    let(:bank_account) { FactoryBot.create(:bank_account, :user_id => user.id, :parser => FactoryBot.create(:chase_parser)) }
    let(:bank_statement_attrs) do
      {
        :month => 1,
        :year => 2017,
        :bank_account_id => bank_account.id,
        :records_text => file_fixture('plain_text_statements/chase_statement_valid.txt').read
      }
    end

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      post :create, params: {param_key => {:month => 1, :year => 2017}}
      expect_to_redirect_log_in_page
    end

    it "should not create bank statement without params" do
      sign_in(user)

      expect {
        post :create, params: {}
      }.to_not change { BankStatement.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should gracefully fail when at least one of the records is invalid" do
      sign_in(user)

      attrs = bank_statement_attrs.merge(:records_text => file_fixture('plain_text_statements/chase_statement_invalid.txt').read)
      expect {
        post :create, params: {param_key => attrs}
      }.to_not change { BankStatement.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should gracefully fail when at least one of the records failed to be saved" do
      allow_any_instance_of(StatementRecord).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new)
      expect(RollbarHelper).to receive(:error).once.with("Unable to save records", {:fingerprint=> :statements_controller_cant_save_records, :e => anything()})

      sign_in(user)

      expect {
        post :create, params: {param_key => bank_statement_attrs}
      }.to_not change { BankStatement.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create bank statement with invalid params" do
      sign_in(user)

      expect {
        post :create, params: {param_key => {:invalid => 'Test statement'}}
      }.to_not change { BankStatement.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create bank statement if there is already an existing one for that account and dates" do
      sign_in(user)

      BankStatement.create!(bank_statement_attrs.except(:records_text).merge(:user_id => user.id))
      expect {
        post :create, params: {param_key => bank_statement_attrs}
      }.to_not change { BankStatement.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should create the bank statement and returns a success response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => bank_statement_attrs}
      }.to change { user.bank_statements.count }.by(1)
      expect(response).to redirect_to(bank_statement_url(assigns[:bank_statement]))
      # expect(flash[:notice]).to be_present
    end

    it "should create the bank statement and returns a success JSON response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => bank_statement_attrs}, format: :json
        expect(response).to be_success
      }.to change { user.bank_statements.count }.by(1)

      assert_json_bank_statement(hash_from_json_body, assigns[:bank_statement])
    end
  end

  describe "PUT #update" do
    let(:other_bank_statement) { FactoryBot.create(:bank_statement) }
    let(:my_bank_statement) { FactoryBot.create(:bank_statement, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      put :update, params: {:id => my_bank_statement.id, param_key => {:month => 1}}
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the bank statement does not exist" do
      sign_in(user)

      put :update, params: {:id => 999999}
      expect_to_render_404
    end

    it "should not update bank statement without params" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_bank_statement.id}
      }.to_not change { my_bank_statement.reload }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "should not update the bank statement with only invalid params but returns a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_bank_statement.id, param_key => {:invalid => 'Test'}}
      }.to_not change { my_bank_statement.reload }
      expect(response).to redirect_to(bank_statement_url(my_bank_statement))
      expect(flash[:notice]).to be_present
    end

    it "should return a 404 response when the bank statement does not exist" do
      sign_in(user)

      expect {
        put :update, params: {:id => other_bank_statement.id, param_key => {:year => 2011}}
      }.to_not change { other_bank_statement.reload.name }
      expect_to_render_404
    end

    it 'should not update the bank statement if changing the date to one that is already taken' do
      sign_in(user)
      new_year = my_bank_statement.year + 1
      existing_statement = BankStatement.create!(my_bank_statement.attributes.slice(*%w(month user_id bank_account_id)).merge(:year => new_year))

      expect {
        put :update, params: {:id => my_bank_statement.id, param_key => {:year => new_year}}
      }.to_not change { my_bank_statement.reload.year }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "update the bank statement and returns a success response" do
      sign_in(user)
      new_year = my_bank_statement.year + 1

      expect {
        put :update, params: {:id => my_bank_statement.id, param_key => {:year => new_year}}
      }.to change { my_bank_statement.reload.year }.to(new_year)
      expect(response).to redirect_to(bank_statement_url(my_bank_statement))
      expect(flash[:notice]).to be_present
    end

    it "update the bank statement and returns a success JSON response" do
      sign_in(user)
      new_year = my_bank_statement.year + 1

      expect {
        put :update, params: {:id => my_bank_statement.id, param_key => {:year => new_year}}, format: :json
        expect(response).to be_success
      }.to change { my_bank_statement.reload.year }.to(new_year)

      json = assert_json_bank_statement(hash_from_json_body, my_bank_statement.reload)
      expect(json[:year]).to eq(new_year)
    end
  end

  describe "DELETE #destroy" do
    let!(:my_bank_statement) { FactoryBot.create(:bank_statement, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      expect {
        delete :destroy, params: {:id => my_bank_statement.id}
      }.to_not change { BankStatement.count }
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the bank statement does not exist" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => 999999}
      }.to_not change { BankStatement.count }
      expect_to_render_404
    end

    it "should return a 404 response when trying to delete someone else's statement" do
      sign_in(user)

      other_bank_statement = FactoryBot.create(:bank_statement)
      expect {
        delete :destroy, params: {:id => other_bank_statement.id}
      }.to_not change { BankStatement.count }
      expect_to_render_404
    end

    it "should gracefully fail if the statement cannot be removed" do
      sign_in(user)
      allow_any_instance_of(BankStatement).to receive(:destroy).and_return false

      expect {
        delete :destroy, params: {:id => my_bank_statement.id}
      }.to_not change { BankStatement.count }
      expect(response).to redirect_to(bank_statement_url(my_bank_statement))
      # expect(flash[:error]).to be_present
    end

    it "should delete the bank statement of that user" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_bank_statement.id}
      }.to change { BankStatement.count }.by(-1)
      expect(response).to redirect_to(bank_statements_url)
      expect(flash[:notice]).to be_present
    end

    it "should delete the bank statement of that user and return an empty JSON response" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_bank_statement.id}, format: :json
        expect(response).to be_success
      }.to change { BankStatement.count }.by(-1)

      expect(response.body).to be_blank
    end
  end

end
