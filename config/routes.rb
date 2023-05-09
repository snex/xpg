# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  post 'process_transaction', defaults: { format: :json }, to: 'payments#process_transaction'
  resources :invoices, except: %i[new edit], defaults: { format: :json }
  resources :wallets do
    member do
      get 'status'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'wallets#index'
end
