# frozen_string_literal: true

class InvoicesController < ApiController
  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      render :show, status: :created
    else
      render json: { errors: @invoice.errors }, status: :unprocessable_entity
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:wallet_id, :amount, :expires_at, :external_id, :callback_url)
  end
end
