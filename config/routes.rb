Rails.application.routes.draw do
  resources :audits, :only => [:index]
  resources :bank_accounts
  resources :bank_statements do
    resources :statement_records
  end
  resources :statement_records
  resources :statement_parsers
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions' }

  root 'application#index'

  match "/404", :to => "errors#not_found", :via => :all
  match "/422", :to => "errors#unprocessable_entity", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
end
