# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :wallet

  validates :amount,       presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :expires_at,   presence: true
  validates :external_id,  presence: true
  validates :callback_url, presence: true

  encrypts :amount, :incoming_address, :external_id, :callback_url

  before_create :generate_incoming_address

  private

  def generate_incoming_address
    self.incoming_address = wallet.generate_incoming_address
  end
end
