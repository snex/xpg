# frozen_string_literal: true

class WalletCreator
  include ActiveModel::Model

  attr_accessor :address, :view_key, :restore_height, :name, :port

  validates :address,  presence: true
  validates :view_key, presence: true
  validate :validate_wallet

  delegate :to_param, to: :wallet

  def self.model_name
    Wallet.model_name
  end

  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      wallet.save!
    end

    SpawnCreateRpcWalletJob.perform_async(wallet.reload.id, address, view_key, restore_height)
  end

  def wallet
    @wallet ||= Wallet.new(name: name, port: port)
  end

  private

  def validate_wallet
    return true if wallet.valid?

    wallet.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
