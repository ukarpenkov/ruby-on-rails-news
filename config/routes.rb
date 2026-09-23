Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :articles, only: [ :show ] do
    resource :favorite, only: [ :create, :destroy ]
  end

  resources :favorites, only: [ :index ]

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # POST /auth/facebook is handled by OmniAuth when the app keys are set.
  # This route answers only before those keys exist.
  post "/auth/facebook", to: "oauth#facebook_unavailable"
  get "/auth/facebook/callback", to: "oauth#facebook"
  get "/auth/failure", to: "oauth#failure"

  get "signup", to: "users#new"
  post "signup", to: "users#create"

  root to: "main#index"
end
