require 'spec_helper'

RSpec.describe ErrorsController, type: :controller do

  describe "GET #404" do
    it 'should properly render the custom error page' do
      get :not_found
      expect(response.status).to eq(404)
    end
  end

  describe "GET #422" do
    it 'should properly render the custom error page' do
      get :unprocessable_entity
      expect(response.status).to eq(422)
    end
  end

  describe "GET #500" do
    it 'should properly render the custom error page' do
      get :internal_server_error
      expect(response.status).to eq(500)
    end
  end

end
