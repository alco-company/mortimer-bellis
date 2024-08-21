Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/solid_queue_jobs"

  devise_for :users, controllers: {
    invitations: "users/invitations",
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :events
  resources :holidays
  resources :calendars do
    resources :events
  end

  get "tooltips/show"

  resources :dashboards
  resources :background_jobs
  resources :pages
  resources :users do
    collection do
      get "sign_in_success"
    end
  end
  resources :punches do
    resource :tooltip, only: :show
  end
  resources :punch_cards do
    resources :punches
  end
  resources :employees do
    resources :calendars
    member do
      post :archive
    end
    collection do
      post :signup
    end
  end
  resources :employee_invitations
  resources :teams do
    resources :calendars
  end
  resources :punch_clocks
  resources :locations do
    resources :punch_clocks
  end
  resources :filters
  resources :accounts do
    resources :calendars
  end

  scope "pos" do
    get "punch_clock" => "pos/punch_clock#show", as: :pos_punch_clock
    get "punch_clock/edit" => "pos/punch_clock#edit", as: :pos_punch_clock_edit
    post "punch_clock" => "pos/punch_clock#create", as: :pos_punch_clock_create

    get "employee" => "pos/employee#show", as: :pos_employee
    get "employees" => "pos/employee#index", as: :pos_employees
    get "employee/punches" => "pos/employee#punches", as: :pos_employee_punches
    get "employee/edit" => "pos/employee#edit", as: :pos_employee_edit
    get "employee/signup_success" => "pos/employee#signup_success", as: :pos_employee_signup_success
    post "employee" => "pos/employee#create", as: :pos_employee_create
    # put "employee" => "pos/employee#update", as: :pos_employee_update
    patch "employee" => "pos/employee#update", as: :pos_employee_update
    delete "employee" => "pos/employee#destroy", as: :pos_employee_delete
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :modal, controller: "modal"

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "dashboards#show"
end
