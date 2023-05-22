# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      post 'process_transaction', defaults: { format: :json }, to: 'payments#process_transaction'
      resources :invoices, only: %i[create show], defaults: { format: :json }
    end
  end

  resources :wallets, except: :show do
    member do
      get 'status'
    end
  end

  root 'wallets#index'
end
