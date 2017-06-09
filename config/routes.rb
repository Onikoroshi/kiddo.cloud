Rails.application.routes.draw do
  resources :time_disputes
  devise_for :users, :controllers => { :registrations => "users/registrations" }

  resources :receptionist, only: [:index], path: "direct"
  resources :attendance_router, only: :index

  resources :accounts, only: [:new, :create, :show, :index] do
    resources :steps, only: [:show, :update], controller: 'account/steps'
  end

  namespace :child do
    resources :attendance_display, only: :index
  end

  namespace :staff do
    resources :attendance_display, only: :index
  end


  root to: "static#dkk", constraints: { subdomain: "daviskidsklub" }
  root to: "static#bethelkids", constraints: { subdomain: "bethelkids" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
