Rails.application.routes.draw do
  resources :situations, only: %i[index show new create] do
    resources :tasks, only: %i[index create update destroy]
    resource :position, only: %i[edit update]
    resource :completion, only: :show, module: :situations
    resource :task_generation, only: :create
  end

  root "home#index"
  get "/terms", to: "terms#show"
  get "/privacy", to: "privacy#show"
  resource :user, only: :destroy

  get "up" => "rails/health#show", as: :rails_health_check

  get "auth/:provide/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
