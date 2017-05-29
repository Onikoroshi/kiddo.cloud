Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations" }

  resources :receptionist, only: [:index], path: "direct"

  resources :cores, only: [:new, :create, :show, :index] do
    resources :steps, only: [:show, :update], controller: 'core/steps'
  end

  root to: "static#home"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
