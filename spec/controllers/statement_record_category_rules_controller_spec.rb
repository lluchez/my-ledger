require 'spec_helper'

RSpec.describe StatementRecordCategoryRulesController, type: :controller do
  render_views

  let(:param_key) {:statement_record_category_rules_category_rule_base }
  let(:user) { FactoryBot.create(:user) }

  describe "GET #index" do
    let!(:rule) { FactoryBot.create(:text_category_rule, :user_id => user.id) }
    let!(:other_rule) { FactoryBot.create(:text_category_rule) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      get :index, params: {}
      expect_to_redirect_log_in_page
    end

    it "should return a success response" do
      sign_in(user)

      get :index, params: {}
      expect(response).to be_successful
    end

    it "should return a success JSON response" do
      sign_in(user)

      get :index, params: {}, format: :json
      expect(response).to be_successful

      data = JSON.parse(response.body)
      expect(data.count).to eq(1)
      ids = data.map{ |o| o["id"] }
      expect(ids).to include(rule.id)
      expect(ids).to_not include(other_rule.id)
      assert_json_statement_record_category_rule(data.first, rule)
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
      expect(response).to be_successful
    end
  end

  describe "GET #show/#edit" do
    let(:owner) { FactoryBot.create(:user) }
    let(:statement_record_category_rule) { FactoryBot.create(:text_category_rule, :user_id => owner.id) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record_category_rule.id}
        expect_to_redirect_log_in_page
      end
    end

    it "should return a 404 response when the category rule does not exist" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => 999999}
        expect_to_render_404
      end
    end

    it "should return a 404 response when the category rule does not belong to the current user" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record_category_rule.id}
        expect_to_render_404
      end
    end

    it "should return a success response" do
      sign_in(owner)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record_category_rule.id}
        expect(response).to be_successful
      end
    end

    it "should return a success JSON response" do
      sign_in(owner)

      get :show, params: {:id => statement_record_category_rule.id}, format: :json
      expect(response).to be_successful

      assert_json_statement_record_category_rule(hash_from_json_body, statement_record_category_rule)
    end
  end

  describe "POST #create" do
    let(:category) { FactoryBot.create(:statement_record_category) }
    let(:category_rule_attrs) do
      FactoryBot.attributes_for(:text_category_rule).merge(:category_id => category.id)
    end

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      post :create, params: {param_key => category_rule_attrs}
      expect_to_redirect_log_in_page
    end

    it "should not create category rule without params" do
      sign_in(user)

      expect {
        post :create, params: {}
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create category rule with invalid params" do
      sign_in(user)

      expect {
        post :create, params: {param_key => {:active => true, :abc => true}}
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    context 'when run_upon_update is falsey or missing' do
      it "should create the category rule, returns a success response and do not update existing records" do
        sign_in(user)
        record = FactoryBot.create(:statement_record, :user => user, :description => 'abc 123', :category_id => nil)

        expect {
          post :create, params: {param_key => category_rule_attrs.merge(:pattern => 'abc')} #, :run_upon_update => '0'}
        }.to change { user.statement_record_category_rules.count }.by(1)
        expect(response).to redirect_to(statement_record_category_rules_url)
        # expect(flash[:notice]).to be_present
        created_rule = assigns[:category_rule]

        # make sure the record has been updated
        record.reload
        expect(record.category_id).to be(nil)
        expect(record.category_rule_id).to be(nil)
      end
    end

    context 'when run_upon_update is true' do
      it "should create the category rule, returns a success response and update existing records" do
        sign_in(user)
        record = FactoryBot.create(:statement_record, :user => user, :description => 'abc 123', :category_id => nil)

        expect {
          post :create, params: {param_key => category_rule_attrs.merge(:pattern => 'abc'), :run_upon_update => '1'}
        }.to change { user.statement_record_category_rules.count }.by(1)
        expect(response).to redirect_to(statement_record_category_rules_url)
        # expect(flash[:notice]).to be_present
        created_rule = assigns[:category_rule]

        # make sure the record has been updated
        record.reload
        expect(record.category_id).to eq(created_rule.category_id)
        expect(record.category_rule_id).to eq(created_rule.id)
      end
    end

    it "should create the category rule and returns a success JSON response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => category_rule_attrs}, format: :json
        expect(response).to be_successful
      }.to change { user.statement_record_category_rules.count }.by(1)

      assert_json_statement_record_category_rule(hash_from_json_body, assigns[:category_rule])
    end
  end

  describe "PUT #update" do
    let(:other_statement_record_category_rule) { FactoryBot.create(:text_category_rule) }
    let(:my_statement_record_category_rule) { FactoryBot.create(:text_category_rule, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      put :update, params: {:id => my_statement_record_category_rule.id, param_key => {:name => 'New Name'}}
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the category rule does not exist" do
      sign_in(user)

      put :update, params: {:id => 999999}
      expect_to_render_404
    end

    it "should not update category rule without params" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_statement_record_category_rule.id}
      }.to_not change { my_statement_record_category_rule.reload }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "should not update the category rule with only invalid params but returns a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_statement_record_category_rule.id, param_key => {:invalid => 'Test'}}
      }.to_not change { my_statement_record_category_rule.reload }
      expect(response).to redirect_to(statement_record_category_rules_url)
      expect(flash[:notice]).to be_present
    end

    it "should return a 404 response when the category rule does not exist" do
      sign_in(user)

      expect {
        put :update, params: {:id => other_statement_record_category_rule.id, param_key => {:name => 'New Name'}}
      }.to_not change { other_statement_record_category_rule.reload.name }
      expect_to_render_404
    end

    it "update the category rule and returns a success response" do
      sign_in(user)
      new_name = 'New Name'

      expect {
        put :update, params: {:id => my_statement_record_category_rule.id, param_key => {:name => new_name}}
      }.to change { my_statement_record_category_rule.reload.name }.to(new_name)
      expect(response).to redirect_to(statement_record_category_rules_url)
      expect(flash[:notice]).to be_present
    end

    it "update the category rule and returns a success response" do
      sign_in(user)
      new_name = 'New Name'

      expect {
        put :update, params: {:id => my_statement_record_category_rule.id, param_key => {:name => new_name}}, format: :json
        expect(response).to be_successful
      }.to change { my_statement_record_category_rule.reload.name }.to(new_name)

      json = assert_json_statement_record_category_rule(hash_from_json_body, my_statement_record_category_rule.reload)
      expect(json[:name]).to eq(new_name)
    end
  end

  describe "DELETE #destroy" do
    let!(:my_statement_record_category_rule) { FactoryBot.create(:text_category_rule, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      expect {
        delete :destroy, params: {:id => my_statement_record_category_rule.id}
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the category rule does not exist" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => 999999}
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
      expect_to_render_404
    end

    it "should return a 404 response when trying to delete someone else's category rule" do
      sign_in(user)

      other_rule = FactoryBot.create(:text_category_rule)
      expect {
        delete :destroy, params: {:id => other_rule.id}
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
      expect_to_render_404
    end

    it "should gracefully fail if the category rule cannot be removed" do
      sign_in(user)
      allow_any_instance_of(StatementRecordCategoryRules::CategoryRuleBase).to receive(:destroy).and_return false

      expect {
        delete :destroy, params: {:id => my_statement_record_category_rule.id}
      }.to_not change { StatementRecordCategoryRules::CategoryRuleBase.count }
      expect(response).to redirect_to(statement_record_category_rule_url(my_statement_record_category_rule))
      # expect(flash[:error]).to be_present
    end

    it "should delete the category rule of that user" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record_category_rule.id}
      }.to change { StatementRecordCategoryRules::CategoryRuleBase.count }.by(-1)
      expect(response).to redirect_to(statement_record_category_rules_url)
      expect(flash[:notice]).to be_present
    end

    it "should delete the category rule of that user and return an empty JSON response" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record_category_rule.id}, format: :json
        expect(response).to be_successful
      }.to change { StatementRecordCategoryRules::CategoryRuleBase.count }.by(-1)

      expect(response.body).to be_blank
    end
  end

end
