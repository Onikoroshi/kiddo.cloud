Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations" }

  resources :receptionist, only: [:index], path: "direct"
  resource :attendance_router, only: :show, controller: "attendance_router", path: "manage"

  resources :accounts, only: [:new, :create, :show, :index] do
    resources :steps, only: [:show, :update], controller: 'account/steps'
    resources :children, controller: 'account/children'
    resource :dashboard, only: :show, controller: 'account/dashboards'
  end

  namespace :children do
    resources :attendance_display, only: :index

  end

  namespace :staff do
    resources :time_disputes, only: [:index, :new, :create]
    resources :attendance_display, only: :index
  end

  resources :time_entries, only: :create
  get "material" => "static#material", as: :material

  root to: "static#dkk", constraints: { subdomain: "daviskidsklub" }
  root to: "static#bethelkids", constraints: { subdomain: "bethelkids" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
