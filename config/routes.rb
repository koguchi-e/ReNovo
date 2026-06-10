Rails.application.routes.draw do
  resources :reflections, only: %i[index show new create]
  root "home#index"

  get "/home", to: "home#show"

  get "up" => "rails/health#show", as: :rails_health_check

  get "auth/:provide/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
