require 'spec_helper'

RSpec.describe StatementRecordsController, type: :controller do
  render_views

  let(:param_key) { :statement_record }
  let(:user) { FactoryBot.create(:user) }

  describe "GET #index" do
    let!(:statement_record) { FactoryBot.create(:statement_record, :user_id => user.id) }
    let!(:other_statement_record) { FactoryBot.create(:statement_record) }

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
      expect(ids).to include(statement_record.id)
      expect(ids).to_not include(other_statement_record.id)
      assert_json_statement_record(data.first, statement_record)
      expect(data.first["statement_name"]).to eq(statement_record.statement.name)
    end

    it "should return a 404 response when providing an incorrect bank statement ID" do
      sign_in(user)
      bank_statement = FactoryBot.create(:bank_statement)

      get :index, params: {:bank_statement_id => bank_statement.id}
      expect_to_render_404
    end

    it "should return a success response when providing a valid bank statement ID" do
      sign_in(user)
      bank_statement = FactoryBot.create(:bank_statement, :user_id => user.id)

      get :index, params: {:bank_statement_id => bank_statement.id}
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
    let(:owner) { FactoryBot.create(:user) }
    let(:statement_record) { FactoryBot.create(:statement_record, :user_id => owner.id) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record.id}
        expect_to_redirect_log_in_page
      end
    end

    it "should return a 404 response when the statement record does not exist" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => 999999}
        expect_to_render_404
      end
    end

    it "should return a 404 response when the statement record does not belong to the current user" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record.id}
        expect_to_render_404
      end
    end

    it "should return a success response" do
      sign_in(owner)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record.id}
        expect(response).to be_success
      end
    end

    it "should return a success JSON response" do
      sign_in(owner)

      get :show, params: {:id => statement_record.id}, format: :json
      expect(response).to be_success

      assert_json_statement_record(hash_from_json_body, statement_record)
    end

    it "should return a 404 response when providing an incorrect bank statement ID" do
      sign_in(owner)
      other_statement = FactoryBot.create(:bank_statement)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record.id, :bank_statement_id => other_statement.id}
        expect_to_render_404
      end
    end

    it "should return a success response when providing the bank statement ID" do
      sign_in(owner)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record.id, :bank_statement_id => statement_record.statement_id}
        expect(response).to be_success
      end
    end
  end

  describe "POST #create" do
    let(:bank_statement) { FactoryBot.create(:bank_statement, :user_id => user.id) }
    let(:statement_record_attrs) do
      {
        :statement_id => bank_statement.id,
        :date => Date.today,
        :description => "Description for Transaction",
        :amount => 159.99
      }
    end

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      post :create, params: {param_key => statement_record_attrs.except(:statement_id)}
      expect_to_redirect_log_in_page
    end

    it "should not create statement record without params" do
      sign_in(user)

      expect {
        post :create, params: {}
      }.to_not change { StatementRecord.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should gracefully fail when at least one of the attributes is invalid" do
      sign_in(user)

      attrs = statement_record_attrs.merge(:date => nil)
      expect {
        post :create, params: {param_key => attrs}
      }.to_not change { StatementRecord.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not allow to associate a statement record to a bank statement belonging to another user" do
      sign_in(user)

      other_statement = FactoryBot.create(:bank_statement)
      attrs = statement_record_attrs.merge(:statement_id => other_statement.id)
      expect {
        post :create, params: {param_key => attrs}
      }.to_not change { StatementRecord.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create statement record with invalid params" do
      sign_in(user)

      expect {
        post :create, params: {param_key => {:invalid => 'Test statement'}}
      }.to_not change { StatementRecord.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should create the statement record and returns a success response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => statement_record_attrs}
      }.to change { user.statement_records.count }.by(1)
      expect(response).to redirect_to(statement_record_url(assigns[:statement_record]))
      # expect(flash[:notice]).to be_present
    end

    it "should create the bank record and returns a success JSON response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => statement_record_attrs}, format: :json
        expect(response).to be_success
      }.to change { user.statement_records.count }.by(1)

      assert_json_statement_record(hash_from_json_body, assigns[:statement_record])
    end
  end

  describe "PUT #update" do
    let(:my_statement_record) { FactoryBot.create(:statement_record, :user => user) }
    let(:other_statement_record) { FactoryBot.create(:statement_record) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      put :update, params: {:id => my_statement_record.id, param_key => {:month => 1}}
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the statement record does not exist" do
      sign_in(user)

      put :update, params: {:id => 999999}
      expect_to_render_404
    end

    it "should not update statement record without params but return a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_statement_record.id}
      }.to_not change { my_statement_record.reload }
      expect(subject).to redirect_to(statement_record_url(my_statement_record))
      expect(flash[:notice]).to be_present
    end

    it "should not update the statement record with only invalid params but returns a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_statement_record.id, param_key => {:invalid => 'Test'}}
      }.to_not change { my_statement_record.reload }
      expect(response).to redirect_to(statement_record_url(my_statement_record))
      expect(flash[:notice]).to be_present
    end

    it "should return a 404 response when the statement record does not exist" do
      sign_in(user)

      expect {
        put :update, params: {:id => other_statement_record.id, param_key => {:amount => 9.99}}
      }.to_not change { other_statement_record.reload.name }
      expect_to_render_404
    end

    it "should not allow to associate a statement record to a bank statement belonging to another user" do
      sign_in(user)
      other_statement = FactoryBot.create(:bank_statement)

      expect {
        put :update, params: {:id => my_statement_record.id, param_key => {:amount => 9.99, :statement_id => other_statement.id}}
      }.to_not change { my_statement_record.reload }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "update the statement record and returns a success response" do
      sign_in(user)
      new_amount = 9.99

      expect {
        put :update, params: {:id => my_statement_record.id, param_key => {:amount => new_amount}}
      }.to change { my_statement_record.reload.amount }.to(new_amount)
      expect(response).to redirect_to(statement_record_url(my_statement_record))
      expect(flash[:notice]).to be_present
    end

    it "update the bank record and returns a success JSON response" do
      sign_in(user)
      new_amount = 9.99

      expect {
        put :update, params: {:id => my_statement_record.id, param_key => {:amount => new_amount}}, format: :json
        expect(response).to be_success
      }.to change { my_statement_record.reload.amount }.to(new_amount)

      json = assert_json_statement_record(hash_from_json_body, my_statement_record.reload)
      expect(json[:amount]).to eq(new_amount)
    end

    it "update the statement record, returns a success response and redirect to the correct page" do
      sign_in(user)
      new_amount = 9.99
      statement = my_statement_record.statement

      expect {
        put :update, params: {:id => my_statement_record.id, :bank_statement_id => statement.id, param_key => {:amount => new_amount}}
      }.to change { my_statement_record.reload.amount }.to(new_amount)
      expect(response).to redirect_to(bank_statement_statement_record_url(statement, my_statement_record))
      expect(flash[:notice]).to be_present
    end
  end

  describe "DELETE #destroy" do
    let!(:my_statement_record) { FactoryBot.create(:statement_record, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      expect {
        delete :destroy, params: {:id => my_statement_record.id}
      }.to_not change { StatementRecord.count }
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the statement record does not exist" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => 999999}
      }.to_not change { StatementRecord.count }
      expect_to_render_404
    end

    it "should return a 404 response when trying to delete someone else's statement record" do
      sign_in(user)

      other_statement_record = FactoryBot.create(:statement_record)
      expect {
        delete :destroy, params: {:id => other_statement_record.id}
      }.to_not change { StatementRecord.count }
      expect_to_render_404
    end

    it "should gracefully fail if the statement record cannot be removed" do
      sign_in(user)
      allow_any_instance_of(StatementRecord).to receive(:destroy).and_return false

      expect {
        delete :destroy, params: {:id => my_statement_record.id}
      }.to_not change { StatementRecord.count }
      expect(response).to redirect_to(statement_records_url)
      # expect(flash[:error]).to be_present
    end

    it "should delete the statement record of that user" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record.id}
      }.to change { StatementRecord.count }.by(-1)
      expect(response).to redirect_to(statement_records_url)
      expect(flash[:notice]).to be_present
    end

    it "should delete the statement of that user and return an empty JSON response" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record.id}, format: :json
        expect(response).to be_success
      }.to change { StatementRecord.count }.by(-1)

      expect(response.body).to be_blank
    end

    it "should not delete the statement record when providing an invalid bank statement ID" do
      sign_in(user)
      other_statement = FactoryBot.create(:bank_statement)

      expect {
        delete :destroy, params: {:id => my_statement_record.id, :bank_statement_id => other_statement.id}
      }.to_not change { StatementRecord.count }
      expect_to_render_404
    end

    it "should delete the statement record of that user and return to the corect page when bank statement ID is provided" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record.id, :bank_statement_id => my_statement_record.statement_id}
      }.to change { StatementRecord.count }.by(-1)
      expect(response).to redirect_to(bank_statement_statement_records_url(my_statement_record.statement))
      expect(flash[:notice]).to be_present
    end
  end

end
