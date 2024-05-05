Rails.application.routes.draw do
  resources :pages
  devise_for :users, controllers: {
    invitations: "users/invitations",
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :users
  resources :punches
  resources :punch_cards do
    # resources :punches
  end
  resources :employees
  resources :teams
  resources :punch_clocks
  resources :locations do
    resources :punch_clocks
  end
  resources :filters
  resources :accounts

  scope "pos" do
    get "punch_clock" => "pos/punch_clock#show", as: :pos_punch_clock
    get "punch_clock/edit" => "pos/punch_clock#edit", as: :pos_punch_clock_edit
    post "punch_clock" => "pos/punch_clock#create", as: :pos_punch_clock_create

    get "employee" => "pos/employee#show", as: :pos_employee
    get "employees" => "pos/employee#index", as: :pos_employees
    get "employee/edit" => "pos/employee#edit", as: :pos_employee_edit
    post "employee" => "pos/employee#create", as: :pos_employee_create
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "modal/new"
  get "modal/show"
  post "modal/create"

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "employees#index"
end
