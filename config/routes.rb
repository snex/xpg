# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  post 'process_transaction', defaults: { format: :json }, to: 'payments#process_transaction'
  resources :invoices, only: :create, defaults: { format: :json }
  resources :wallets, except: :show do
    member do
      get 'status'
    end
  end

  root 'wallets#index'
end
