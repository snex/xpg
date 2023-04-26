# frozen_string_literal: true

json.array! @wallets, partial: 'wallets/wallet', as: :wallet
