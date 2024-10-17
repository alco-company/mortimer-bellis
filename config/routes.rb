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

  post "dinero/callback" => "dinero#callback", as: :dinero_callback

  resources :time_materials

  resources :invoice_items

  resources :products do
    collection do
      get "erp_pull"
    end
  end
  resources :customers do
    collection do
      get "erp_pull"
      get "lookup"
    end
  end
  resources :invoices do
    collection do
      get "erp_pull"
    end
  end

  resources :projects

  resources :provided_services
  resources :settings
  resources :events
  resources :notifications
  resources :holidays
  resources :calendars do
    resources :events
  end

  get "tooltips/show"

  resources :dashboards
  resources :background_jobs
  resources :pages
  resources :users do
    resources :calendars
    collection do
      get "sign_in_success"
    end
    member do
      post :archive
    end
  end
  resources :punches do
    resource :tooltip, only: :show
  end
  resources :punch_cards do
    resources :punches
  end
  # resources :employees do
  #   resources :calendars
  #   member do
  #     post :archive
  #   end
  #   collection do
  #     post :signup
  #   end
  # end
  resources :teams do
    resources :calendars
  end
  resources :punch_clocks
  resources :locations do
    resources :punch_clocks
  end
  resources :filters
  resources :tenants do
    resources :calendars
  end

  scope "pos" do
    get "punch_clock" => "pos/punch_clock#show", as: :pos_punch_clock
    get "punch_clock/edit" => "pos/punch_clock#edit", as: :pos_punch_clock_edit
    post "punch_clock" => "pos/punch_clock#create", as: :pos_punch_clock_create

    get "user" => "pos/user#show", as: :pos_user
    get "users" => "pos/user#index", as: :pos_users
    get "user/punches" => "pos/user#punches", as: :pos_user_punches
    get "user/edit" => "pos/user#edit", as: :pos_user_edit
    get "user/signup_success" => "pos/user#signup_success", as: :pos_user_signup_success
    post "user" => "pos/user#create", as: :pos_user_create
    # put "user" => "pos/user#update", as: :pos_user_update
    patch "user" => "pos/user#update", as: :pos_user_update
    delete "user" => "pos/user#destroy", as: :pos_user_delete
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
  root "dashboards#show_dashboard"
end
