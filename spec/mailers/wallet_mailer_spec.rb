# frozen_string_literal: true

RSpec.describe WalletMailer do
  describe '#payment_without_invoice' do
    include_context 'when MoneroRPC::IncomingTransfer is needed'

    let(:wallet) { build(:wallet, name: 'lolwallet') }
    let(:mail) { described_class.with(wallet: wallet, transaction: tx).payment_without_invoice }
    let(:expected_body) { File.readlines('spec/support/mailers/wallet/payment_without_invoice.txt').join }

    before do
      allow(tx).to receive(:address).and_return('1234')
      allow(tx).to receive(:payment_id).and_return('5678')
      allow(tx).to receive(:amount).and_return(10)
      allow(tx).to receive(:txid).and_return('lol')
    end

    it 'renders the sender' do
      expect(mail.from).to contain_exactly('from@fake.fake')
    end

    it 'renders the receiver' do
      expect(mail.to).to contain_exactly('to@fake.fake')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Payment With No Invoice Received')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to eq(expected_body)
    end
  end
end
