# frozen_string_literal: true

class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[show edit update destroy]

  # GET /wallets or /wallets.json
  def index
    @wallets = Wallet.all
  end

  # GET /wallets/1 or /wallets/1.json
  def show; end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
  end

  # GET /wallets/1/edit
  def edit; end

  # POST /wallets or /wallets.json
  def create
    @wallet = Wallet.new(wallet_params)

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

  # PATCH/PUT /wallets/1 or /wallets/1.json
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

  # DELETE /wallets/1 or /wallets/1.json
  def destroy
    @wallet.destroy

    respond_to do |format|
      format.html { redirect_to wallets_url, notice: t(:'wallet.destroyed') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_wallet
    @wallet = Wallet.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def wallet_params
    params.require(:wallet).permit(:name, :password, :rpc_creds, :port)
  end
end
