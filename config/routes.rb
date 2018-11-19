Rails.application.routes.draw do
  get '/dashboard' => 'dashboard#index'
  resources :audits, :only => [:index]
  resources :bank_accounts
  resources :bank_statements do
    resources :statement_records do
      collection do
        get  :upload_csv
        post :import_csv
      end
    end
  end
  resources :statement_records do
    collection do
      get  :upload_csv
      post :import_csv
    end
  end
  resources :statement_record_categories
  resources :statement_record_category_rules
  resources :statement_parsers
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions' }

  match "/test", :to => "test#index", :via => :all

  root 'dashboard#index'

  match "/404", :to => "errors#not_found", :via => :all
  match "/422", :to => "errors#unprocessable_entity", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
end
