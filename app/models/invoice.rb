# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :wallet

  has_many :payments, dependent: :restrict_with_error

  validates :amount,           presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :expires_at,       presence: true
  validates :external_id,      presence: true, uniqueness: { scope: :wallet_id }
  validates :incoming_address, uniqueness: { scope: :payment_id }
  validates :callback_url,     presence: true, url: true

  encrypts :amount, :callback_url
  # Need deterministic encryption in order to support search and unique constraint
  encrypts :incoming_address, :payment_id, :external_id, deterministic: true

  before_create :generate_incoming_address

  def status
    status = [payment_status]
    status << expiration_status if status.include?(:unpaid)

    status
  end

  private

  def generate_incoming_address
    return if incoming_address? && payment_id?

    integrated_address = wallet.generate_incoming_address
    self.incoming_address = integrated_address['integrated_address']
    self.payment_id = integrated_address['payment_id']
  end

  def payment_status
    # encrypted column means we cant sum it in the database
    amount_paid = payments.pluck(:amount).map(&:to_i).sum

    if amount_paid > amount.to_i
      :overpaid
    elsif amount_paid < amount.to_i
      :unpaid
    else
      :paid
    end
  end

  def expiration_status
    if Time.current < expires_at
      :payable
    else
      :overdue
    end
  end
end
