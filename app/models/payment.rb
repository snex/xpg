# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :invoice

  validates :amount,       presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :monero_tx_id, presence: true, uniqueness: true

  delegate :confirmed?, to: :transfer_details
  delegate :wallet, to: :invoice

  encrypts :amount
  # Need deterministic encryption in order to support search and unique constraint
  encrypts :monero_tx_id, deterministic: true

  private

  def transfer_details
    wallet.transfer_details(monero_tx_id)
  end
end
