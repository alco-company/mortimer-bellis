Rails.application.routes.draw do
  get "home/show"
  # -------- AUTHENTICATION ROUTES --------
  use_doorkeeper do
    controllers applications: "oauth/applications"
  end

  devise_for :users, controllers: {
    invitations: "users/invitations",
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # called by JS on client side to check if the session is still valid
  get "check_session", to: "sessions#check"

  # 2FA routes
  get "auth/edit/2fa/app/init" => "users/second_factor#initiate_new_app", as: :init_new_user_two_factor_app
  post "auth/edit/2fa/app/new" => "users/second_factor#new_app", as: :new_user_two_factor_app
  post "auth/edit/2fa/app" => "users/second_factor#create_app", as: :create_user_two_factor_app
  get "auth/edit/2fa/app/destroy" => "users/second_factor#new_destroy_app", as: :new_destroy_user_two_factor_app
  post "auth/edit/2fa/app/destroy" => "users/second_factor#destroy_app", as: :destroy_user_two_factor_app


  post "web_push_subscriptions" => "noticed/web_push/subscriptions#create", as: :web_push_subscriptions

  # -------- END AUTHENTICATION ROUTES --------

  mount MissionControl::Jobs::Engine, at: "/solid_queue_jobs"

  # -------- API ROUTES & 3RD PARTY --------
  namespace :api do
    namespace :v1 do
      resources :tickets
      resources :contacts do
        collection do
          get "lookup"
        end
      end
      get "hello" => "hello_world#hello"
    end
  end

  post "dinero/callback" => "dinero#callback", as: :dinero_callback

  # -------- END API ROUTES & 3RD PARTY --------

  concern :lookupable do
    collection do
      get "lookup"
    end
  end

  concern :erp_pullable do
    collection do
      get "erp_pull"
    end
  end

  resources :calls
  resources :tasks

  resources :time_materials do
    member do
      post :archive
    end
  end

  resources :invoice_items

  resources :products, concerns: [ :lookupable, :erp_pullable ]
  resources :customers, concerns: [ :lookupable, :erp_pullable ]
  resources :invoices, concerns: [ :erp_pullable ]

  resources :projects, concerns: [ :lookupable ]


  resources :provided_services
  resources :settings
  resources :events
  resources :notifications
  resources :holidays
  resources :calendars do
    resources :events
  end

  get "tooltips/show"

  resources :dashboards do
    collection do
      get "show_dashboard"
    end
  end
  resources :background_jobs
  resources :pages do
    collection do
      get "help"
    end
  end
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
  resources :locations, concerns: [ :lookupable ] do
    resources :punch_clocks
  end
  resources :filters
  resource :filter_fields, only: [ :show, :new ]
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
  # root "dashboards#show_dashboard"
  # root "time_materials#index"
  root "home#show"
end
