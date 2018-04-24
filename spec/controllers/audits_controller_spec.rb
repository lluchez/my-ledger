require 'spec_helper'

def verify_audit_json(data, user, where_clause)
  db_audit = Audit.where(:user => user).where(where_clause).last
  expect(db_audit).to be
  where_clause.each do |k, v|
    data = data.select {|a| a[k.to_s] === v}
  end
  json_audit = data.first
  expect(json_audit).to be
  assert_json_audit(json_audit, db_audit)
end

RSpec.describe AuditsController, type: :controller do
  render_views

  let(:user) { FactoryBot.create(:user) }

  before(:all) do
    enable_audited_on_all_models
  end

  after(:all) do
    disable_audited_on_all_models
  end

  context "User is not signed in" do
    before(:each) do
      sign_in(nil)
    end

    describe "GET #index" do
      it "should redirect to the sign-in page when not logged-in" do
        get :index, params: {}
        expect_to_redirect_log_in_page
      end
    end
  end

  context "User is signed in" do
    before(:each) do
      Audited.store[:audited_user] = user
      sign_in(user)
    end

    describe "GET #index" do
      it "should return a success response" do
        record = FactoryBot.create(:statement_record, :user_id => user.id)

        get :index, params: {}
        expect(response).to be_successful
        expect(response.body).to include(record.description)
      end

      it "should return a success JSON response" do
        FactoryBot.create(:statement_record, :user_id => user.id)

        get :index, params: {}, format: :json
        expect(response).to be_successful

        data = JSON.parse(response.body)
        expect(data.count).to eq(5)

        verify_audit_json(data, user, {:action => 'create', :auditable_type => 'StatementRecord'})
        verify_audit_json(data, user, {:action => 'create', :auditable_type => 'BankStatement'})
        verify_audit_json(data, user, {:action => 'update', :auditable_type => 'BankStatement'})
        verify_audit_json(data, user, {:action => 'create', :auditable_type => 'BankAccount'})
        verify_audit_json(data, user, {:action => 'create', :auditable_type => 'StatementParsers::ParserBase'})
      end
    end
  end
end
