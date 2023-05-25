# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
    mount Sidekiq::Web => '/sidekiq'

    resources :wallets, except: :show do
      member do
        get 'status'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      post 'process_transaction', defaults: { format: :json }, to: 'payments#process_transaction'
      resources :invoices, only: %i[create show], defaults: { format: :json }
    end
  end
end
