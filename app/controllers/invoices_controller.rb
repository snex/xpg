# frozen_string_literal: true

class InvoicesController < ApiController
  before_action :set_invoice, only: %i[show update destroy]

  def index
    @invoices = Invoice.all
  end

  def show; end

  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      render :show, status: :created, location: @invoice
    else
      render json: { errors: @invoice.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @invoice.update(invoice_params)
      render :show, status: :ok, location: @invoice
    else
      render json: { errors: @invoice.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy

    head :no_content
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:wallet_id, :amount, :expires_at, :external_id, :callback_url)
  end
end
