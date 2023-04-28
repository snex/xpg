# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show update destroy]

  # GET /invoices or /invoices.json
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1 or /invoices/1.json
  def show; end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      render :show, status: :created, location: @invoice
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    if @invoice.update(invoice_params)
      render :show, status: :ok, location: @invoice
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy

    head :no_content
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:wallet_id, :amount, :expires_at, :external_id)
  end
end
