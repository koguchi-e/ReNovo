# frozen_string_literal: true

Rails.application.routes.draw do
  resources :situations, only: %i[index show new create] do
    resources :tasks, only: %i[index create update destroy] do
      resource :position, only: %i[update], controller: "tasks/positions"
    end
    resource :task_generation, only: :create
  end

  root "home#index"
  resource :terms, only: :show
  resource :privacy, only: :show, controller: :privacy
  resource :user, only: :destroy

  get "up" => "rails/health#show", as: :rails_health_check

  get "auth/:provider/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
