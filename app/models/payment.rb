# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :invoice

  validates :amount,       presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :monero_tx_id, presence: true, uniqueness: true

  delegate :confirmations, to: :transfer_details
  delegate :confirmed?, to: :transfer_details
  delegate :suggested_confirmations_threshold, to: :transfer_details
  delegate :wallet, to: :invoice

  encrypts :amount
  # Need deterministic encryption in order to support search and unique constraint
  encrypts :monero_tx_id, deterministic: true

  after_create_commit :handle_payment_witnessed

  def necessary_confirmations
    suggested_confirmations_threshold.clamp(1, 10)
  end

  private

  def transfer_details
    wallet.transfer_details(monero_tx_id)
  end

  def handle_payment_witnessed
    HandlePaymentWitnessedJob.perform_async(id)
  end
end
