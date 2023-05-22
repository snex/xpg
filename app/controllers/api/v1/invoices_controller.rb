# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApiController
      wrap_parameters :invoice, include: %i[wallet_name amount external_id expires_at callback_url]

      def show
        @invoice = Invoice.find(params[:id])
      end

      def create
        invoice_creator = InvoiceCreator.new(invoice_params)

        if invoice_creator.save
          @invoice = invoice_creator.invoice
          render :show, status: :created
        else
          render json: { errors: invoice_creator.errors }, status: :unprocessable_entity
        end
      end

      private

      def invoice_params
        params.require(:invoice).permit(:wallet_name, :amount, :expires_at, :external_id, :callback_url)
      end
    end
  end
end
