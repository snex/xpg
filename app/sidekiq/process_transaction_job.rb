# frozen_string_literal: true

class ProcessTransactionJob
  include Sidekiq::Job

  def perform(wallet_id, monero_tx_id)
    Wallet.find(wallet_id).process_transaction(monero_tx_id)
  end
end
