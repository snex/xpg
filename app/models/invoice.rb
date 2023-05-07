# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :wallet

  validates :amount,           presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :expires_at,       presence: true
  validates :external_id,      presence: true, uniqueness: { scope: :wallet_id }
  validates :incoming_address, uniqueness: true
  validates :callback_url,     presence: true, url: true

  encrypts :amount, :callback_url
  # Need deterministic encryption in order to support search and unique constraint
  encrypts :incoming_address, :external_id, deterministic: true

  before_create :generate_incoming_address

  private

  def generate_incoming_address
    return if incoming_address?

    self.incoming_address = wallet.generate_incoming_address
  end
end
