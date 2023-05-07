# frozen_string_literal: true

class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[show edit update destroy status]

  def index
    @wallets = Wallet.all
  end

  def show; end

  def new
    @wallet = WalletCreator.new
  end

  def edit; end

  def create
    @wallet = WalletCreator.new(create_wallet_params)

    respond_to do |format|
      if @wallet.save
        format.html { redirect_to wallet_url(@wallet), notice: t(:'wallet.created') }
        format.json { render :show, status: :created, location: @wallet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @wallet.update(wallet_params)
        format.html { redirect_to wallet_url(@wallet), notice: t(:'wallet.updated') }
        format.json { render :show, status: :ok, location: @wallet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wallet.destroy

    respond_to do |format|
      format.html { redirect_to wallets_url, notice: t(:'wallet.destroyed') }
      format.json { head :no_content }
    end
  end

  def status
    render 'status', layout: false
  end

  private

  def set_wallet
    @wallet = Wallet.find(params[:id])
  end

  def create_wallet_params
    params.require(:wallet).permit(:address, :view_key, :name, :port)
  end

  def wallet_params
    params.require(:wallet).permit(:name, :port)
  end
end
