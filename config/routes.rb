Rails.application.routes.draw do
  resources :chats do
    resources :messages, only: [ :create ]
  end
  resources :models, only: [ :index, :show ] do
    collection do
      post :refresh
    end
  end
  resources :situations, only: %i[index show new create] do
    resources :tasks, only: %i[index create update destroy]
  end

  root "home#index"
  get "/home", to: "home#show"

  get "up" => "rails/health#show", as: :rails_health_check

  get "auth/:provide/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
