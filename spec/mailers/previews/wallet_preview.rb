# frozen_string_literal: true

class WalletPreview < ActionMailer::Preview
  def payment_without_invoice
    wallet = FactoryBot.build(:wallet)
    transaction = MoneroRPC::IncomingTransfer.new(
      address:    '1234',
      payment_id: '5678',
      amount:     10,
      txid:       '9876'
    )
    WalletMailer.with(wallet: wallet, transaction: transaction).payment_without_invoice
  end
end
