require 'spec_helper'

RSpec.describe StatementRecordCategoriesController, type: :controller do
  render_views

  let(:param_key) {:statement_record_category }
  let(:user) { FactoryBot.create(:user) }

  describe "GET #index" do
    let!(:statement_record_category) { FactoryBot.create(:statement_record_category, :user_id => user.id) }
    let!(:other_category) { FactoryBot.create(:statement_record_category) }

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
      expect(ids).to include(statement_record_category.id)
      expect(ids).to_not include(other_category.id)
      assert_json_statement_record_category(data.first, statement_record_category)
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
    let(:statement_record_category) { FactoryBot.create(:statement_record_category, :user_id => owner.id) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record_category.id}
        expect_to_redirect_log_in_page
      end
    end

    it "should return a 404 response when the category does not exist" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => 999999}
        expect_to_render_404
      end
    end

    it "should return a 404 response when the category does not belong to the current user" do
      sign_in(user)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record_category.id}
        expect_to_render_404
      end
    end

    it "should return a success response" do
      sign_in(owner)

      [:show, :edit].each do |method|
        get method, params: {:id => statement_record_category.id}
        expect(response).to be_successful
      end
    end

    it "should return a success JSON response" do
      sign_in(owner)

      get :show, params: {:id => statement_record_category.id}, format: :json
      expect(response).to be_successful

      assert_json_statement_record_category(hash_from_json_body, statement_record_category)
    end
  end

  describe "POST #create" do
    let(:statement_record_category_attrs) { FactoryBot.attributes_for(:statement_record_category) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      post :create, params: {param_key => statement_record_category_attrs}
      expect_to_redirect_log_in_page
    end

    it "should not create category without params" do
      sign_in(user)

      expect {
        post :create, params: {}
      }.to_not change { StatementRecordCategory.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should not create category with invalid params" do
      sign_in(user)

      expect {
        post :create, params: {param_key => {:active => true, :abc => true}}
      }.to_not change { StatementRecordCategory.count }
      expect(subject).to render_template(:new)
      # expect(flash[:error]).to be_present
    end

    it "should create the category and returns a success response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => statement_record_category_attrs}
      }.to change { user.statement_record_categories.count }.by(1)
      expect(response).to redirect_to(statement_record_category_url(assigns[:category]))
      # expect(flash[:notice]).to be_present
    end

    it "should create the category and returns a success JSON response" do
      sign_in(user)

      expect {
        post :create, params: {param_key => statement_record_category_attrs}, format: :json
        expect(response).to be_successful
      }.to change { user.statement_record_categories.count }.by(1)

      assert_json_statement_record_category(hash_from_json_body, assigns[:category])
    end
  end

  describe "PUT #update" do
    let(:other_statement_record_category) { FactoryBot.create(:statement_record_category) }
    let(:my_statement_record_category) { FactoryBot.create(:statement_record_category, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      put :update, params: {:id => my_statement_record_category.id, param_key => {:name => 'New Name'}}
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the category does not exist" do
      sign_in(user)

      put :update, params: {:id => 999999}
      expect_to_render_404
    end

    it "should not update category without params" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_statement_record_category.id}
      }.to_not change { my_statement_record_category.reload }
      expect(subject).to render_template(:edit)
      # expect(flash[:error]).to be_present
    end

    it "should not update the category with only invalid params but returns a successful response" do
      sign_in(user)

      expect {
        put :update, params: {:id => my_statement_record_category.id, param_key => {:invalid => 'Test'}}
      }.to_not change { my_statement_record_category.reload }
      expect(response).to redirect_to(statement_record_category_url(my_statement_record_category))
      expect(flash[:notice]).to be_present
    end

    it "should return a 404 response when the category does not exist" do
      sign_in(user)

      expect {
        put :update, params: {:id => other_statement_record_category.id, param_key => {:name => 'New Name'}}
      }.to_not change { other_statement_record_category.reload.name }
      expect_to_render_404
    end

    it "update the category and returns a success response" do
      sign_in(user)
      new_name = 'New Name'

      expect {
        put :update, params: {:id => my_statement_record_category.id, param_key => {:name => new_name}}
      }.to change { my_statement_record_category.reload.name }.to(new_name)
      expect(response).to redirect_to(statement_record_category_url(my_statement_record_category))
      expect(flash[:notice]).to be_present
    end

    it "update the category and returns a success response" do
      sign_in(user)
      new_name = 'New Name'

      expect {
        put :update, params: {:id => my_statement_record_category.id, param_key => {:name => new_name}}, format: :json
        expect(response).to be_successful
      }.to change { my_statement_record_category.reload.name }.to(new_name)

      json = assert_json_statement_record_category(hash_from_json_body, my_statement_record_category.reload)
      expect(json[:name]).to eq(new_name)
    end
  end

  describe "DELETE #destroy" do
    let!(:my_statement_record_category) { FactoryBot.create(:statement_record_category, :user => user) }

    it "should redirect to the sign-in page when not logged-in" do
      sign_in(nil)

      expect {
        delete :destroy, params: {:id => my_statement_record_category.id}
      }.to_not change { StatementRecordCategory.count }
      expect_to_redirect_log_in_page
    end

    it "should return a 404 response when the category does not exist" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => 999999}
      }.to_not change { StatementRecordCategory.count }
      expect_to_render_404
    end

    it "should return a 404 response when trying to delete someone else's account" do
      sign_in(user)

      other_statement_record_category = FactoryBot.create(:statement_record_category)
      expect {
        delete :destroy, params: {:id => other_statement_record_category.id}
      }.to_not change { StatementRecordCategory.count }
      expect_to_render_404
    end

    it "should gracefully fail if the account cannot be removed" do
      sign_in(user)
      allow_any_instance_of(StatementRecordCategory).to receive(:destroy).and_return false

      expect {
        delete :destroy, params: {:id => my_statement_record_category.id}
      }.to_not change { StatementRecordCategory.count }
      expect(response).to redirect_to(statement_record_category_url(my_statement_record_category))
      # expect(flash[:error]).to be_present
    end

    it "should delete the category of that user" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record_category.id}
      }.to change { StatementRecordCategory.count }.by(-1)
      expect(response).to redirect_to(statement_record_categories_url)
      expect(flash[:notice]).to be_present
    end

    it "should delete the category of that user and return an empty JSON response" do
      sign_in(user)

      expect {
        delete :destroy, params: {:id => my_statement_record_category.id}, format: :json
        expect(response).to be_successful
      }.to change { StatementRecordCategory.count }.by(-1)

      expect(response.body).to be_blank
    end
  end

end
