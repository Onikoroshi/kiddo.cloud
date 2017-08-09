Rails.application.routes.draw do
  devise_for :users,
    path: "/",
    path_names: {
      sign_in: "sign-in",
      sign_out: "sign-out",
      sign_up: "sign-up"
    },
    controllers: { registrations: "users/registrations" }

  resources :receptionist, only: [:index], path: "direct"

  resources :accounts, only: [:new, :create, :show, :index] do
    resources :steps, only: [:show, :update], controller: 'account/steps'
    resources :children, controller: 'account/children'
    resource :subscription, controller: 'account/subscription'
    resources :payments, controller: "account/payments"

    resource :enrollment_type,
      controller: 'account/enrollment_type',
      only: :show,
      path: "plan-options"

    resource :attendance_selection,
      only: [:edit, :update],
      controller: 'account/attendance_selections',
      path: "plans"

    resource :drop_ins, controller: 'account/drop_ins'

    resource :dashboard, controller: 'account/dashboards' do
      get  :my_dropins,     to: "account/manage/drop_ins#index"
      resource :drop_ins, controller: 'account/manage/drop_ins'
      resources :payments, controller: "account/manage/payments"
      resources :children, controller: 'account/manage/children'
      resources :enrollments, controller: "account/manage/enrollments"
    end
  end

  namespace :children do
    resources :attendance_display, only: :index
  end

  namespace :staff do
    resources :time_disputes, only: [:index, :new, :create]
    resources :attendance_display, only: :index
    resource :dashboard, only: :show, controller: 'dashboard'
  end

  resources :time_entries, only: :create
  get "material" => "static#material", as: :material

  root to: redirect("https://iank.us/dkk/")
  #root to: "static#dkk", constraints: { subdomain: "daviskidsklub" }
  #root to: "static#bethelkids", constraints: { subdomain: "bethelkids" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
