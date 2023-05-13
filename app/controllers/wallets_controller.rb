# frozen_string_literal: true

class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[edit update destroy status]

  def index
    @wallets = Wallet.all.order(:id)
  end

  def new
    @wallet = WalletCreator.new
  end

  def edit; end

  def create
    @wallet = WalletCreator.new(create_wallet_params)

    if @wallet.save
      redirect_to wallets_url, notice: t(:'wallet.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @wallet.update(wallet_params)
      redirect_to wallets_url, notice: t(:'wallet.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wallet.destroy

    redirect_to wallets_url, notice: t(:'wallet.destroyed')
  end

  def status
    render 'status', layout: false
  end

  private

  def set_wallet
    @wallet = Wallet.find(params[:id])
  end

  def create_wallet_params
    params.require(:wallet).permit(:address, :view_key, :name, :port, :default_expiry_ttl)
  end

  def wallet_params
    params.require(:wallet).permit(:name, :port, :default_expiry_ttl)
  end
end
