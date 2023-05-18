# frozen_string_literal: true

RSpec.describe InvoiceMailer do
  let(:wallet) { build(:wallet, name: 'lolwallet') }
  let(:invoice) do
    build(:invoice, wallet: wallet, incoming_address: '1234', payment_id: '5678', external_id: 'lolwut', amount: 10)
  end

  describe '#overpayment' do
    let(:mail) { described_class.with(invoice: invoice).overpayment }
    let(:expected_body) { File.readlines('spec/support/mailers/invoice/overpayment.txt').join }

    before { allow(invoice).to receive(:amount_paid).and_return(20) }

    it 'renders the sender' do
      expect(mail.from).to contain_exactly('from@fake.fake')
    end

    it 'renders the receiver' do
      expect(mail.to).to contain_exactly('to@fake.fake')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Overpayment Received')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to eq(expected_body)
    end
  end

  describe '#partial_payment' do
    let(:mail) { described_class.with(invoice: invoice).partial_payment }
    let(:expected_body) { File.readlines('spec/support/mailers/invoice/partial_payment.txt').join }

    before { allow(invoice).to receive(:amount_paid).and_return(20) }

    it 'renders the sender' do
      expect(mail.from).to contain_exactly('from@fake.fake')
    end

    it 'renders the receiver' do
      expect(mail.to).to contain_exactly('to@fake.fake')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Invoice Expiring While Partially Paid')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to eq(expected_body)
    end
  end
end
