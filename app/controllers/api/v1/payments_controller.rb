# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ApiController
      def process_transaction
        wallet = Wallet.find(transaction_params[:wallet_id])
        ProcessTransactionJob.perform_async(wallet.id, transaction_params[:monero_tx_id])

        render json: {}, status: :ok
      end

      private

      def transaction_params
        params.require(:transaction).permit(:wallet_id, :monero_tx_id)
      end
    end
  end
end
