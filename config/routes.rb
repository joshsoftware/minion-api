# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users
      get 'me', to: 'users#me'
    end
  end
  post 'login', to: 'api/v1/auth#login'
  post 'signup', to: 'api/v1/auth#signup'
end
