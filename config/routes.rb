Rails.application.routes.draw do
  devise_for :users,
    path: "/",
    path_names: {
      sign_in: "sign-in",
      sign_out: "sign-out",
      sign_up: "sign-up",
    },
    controllers: { registrations: "users/registrations" }

  namespace :legacy do
    devise_for :users,
    path: "/",
    path_names: {
      sign_up: "confirm/sign-up",
    },
    controllers: { registrations: "users/legacy_registrations" }
  end

  resources :receptionist, only: [:index], path: "direct"

  resources :accounts, only: [:new, :create, :show, :index] do
    resources :steps, only: [:show, :update], controller: 'account/steps'
    resources :children, controller: 'account/children'
    resource :subscription, controller: 'account/subscription'
    resource :checkout, only: [:new, :create], controller: "account/checkouts"
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
      get :my_dropins, to: "account/manage/drop_ins#index"
      resource :credit_card, controller: "account/manage/credit_cards", only: [:show, :new, :create, :destroy]
      resource :drop_ins, controller: 'account/manage/drop_ins'
      resources :payments, controller: "account/manage/payments"
      resources :children, controller: 'account/manage/children'
      resources :enrollments, controller: "account/manage/enrollments", except: [:edit, :update] do
        collection do
          get :edit
          patch :update
          put :update
        end
      end

      resources :parents, controller: "account/manage/parents", only: :index do
        collection do
          get :edit
          patch :update
          put :update
        end
      end

      resource :medical, controller: "account/manage/medical", only: :index do
        collection do
          get :edit
          patch :update
          put :update
        end
      end
    end
  end

  namespace :children do
    resources :attendance_display, only: :index
  end

  namespace :staff do
    resources :programs, except: :show
    resources :plans, except: :show
    resources :locations, except: :show
    resources :announcements, except: :show
    resources :time_entries, except: :show do
      collection do
        get :ratio_report
        get :ratio_csv
      end
    end

    resources :accounts, only: [:index, :show] do
      collection do
        get :export_to_csv
      end
    end

    resources :time_disputes, only: [:index, :new, :create]
    resources :attendance_display, only: :index
    resource :dashboard, only: :show, controller: 'dashboard'
    resources :staff
    resources :transactions, only: [:index, :show]
    resources :enrollments, only: :index do
      collection do
        get :export_to_csv
        patch :set_change_fee_requirement
      end

      member do
        patch :set_change_refund_requirement
      end
    end
  end

  resources :time_entries, only: :create
  get "material" => "static#material", as: :material

  root to: "static#home"
end
