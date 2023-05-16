# frozen_string_literal: true

class InvoiceCreator
  include ActiveModel::Model

  attr_accessor :wallet_name, :amount, :expires_at, :callback_url, :external_id

  validates :wallet_name, presence: true
  validate :validate_invoice

  delegate :to_param, to: :invoice

  def self.model_name
    Invoice.model_name
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      invoice.wallet = wallet
      invoice.save!
    end
  end

  def invoice
    @invoice ||= Invoice.new(wallet: wallet, amount: amount, expires_at: expires_at, callback_url: callback_url,
                             external_id: external_id)
  end

  def wallet
    @wallet ||= Wallet.find_by(name: wallet_name)
  end

  private

  def validate_invoice
    return true if invoice.valid?

    invoice.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
