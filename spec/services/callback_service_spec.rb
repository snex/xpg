# frozen_string_literal: true

RSpec.describe CallbackService do
  let(:cs) { described_class.new(url, body) }
  let(:url) { 'http://www.google.com' }
  let(:body) { { param1: 'value1', param2: 'value2' } }

  before { allow(Net::HTTP).to receive(:post) }

  describe '#call' do
    subject(:call) { cs.call }

    it 'calls Net::HTTP.post' do
      call

      expect(Net::HTTP).to have_received(:post).with(URI.parse(url), body.to_json,
                                                     { 'Content-Type': 'application/json' }).once
    end
  end

  describe '.handle_payment_witnessed' do
    subject(:handle_payment_witnessed) { described_class.handle_payment_witnessed(invoice) }

    let(:invoice) { build(:invoice) }
    let(:expected_body) do
      {
        status:   'payment_witnessed',
        payments: [
          { amount: 1, confirmations: 2, necessary_confirmations: 3 },
          { amount: 4, confirmations: 5, necessary_confirmations: 6 }
        ]
      }
    end

    before do
      allow(invoice).to receive(:payments_witnessed)
        .and_return([
                      { amount: 1, confirmations: 2, necessary_confirmations: 3 },
                      { amount: 4, confirmations: 5, necessary_confirmations: 6 }
                    ])
    end

    it 'calls Net::HTTP.post with the correct body' do
      handle_payment_witnessed

      expect(Net::HTTP).to have_received(:post).with(URI.parse(invoice.callback_url), expected_body.to_json,
                                                     { 'Content-Type': 'application/json' }).once
    end
  end

  describe '.handle_payment_complete' do
    subject(:handle_payment_complete) { described_class.handle_payment_complete(url) }

    let(:expected_body) do
      {
        status: 'payment_complete'
      }
    end

    it 'calls Net::HTTP.post with the correct body' do
      handle_payment_complete

      expect(Net::HTTP).to have_received(:post).with(URI.parse('http://www.google.com'), expected_body.to_json,
                                                     { 'Content-Type': 'application/json' }).once
    end
  end
end
