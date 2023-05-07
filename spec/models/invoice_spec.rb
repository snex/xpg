# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:invoice) { build(:invoice) }

  describe 'associations' do
    subject { build(:invoice) }

    it { is_expected.to belong_to(:wallet) }
  end

  describe 'validations' do
    subject { build(:invoice, wallet: wallet) }

    let(:wallet) { build(:wallet) }

    before { allow(wallet).to receive(:generate_incoming_address).and_return('abcd1234') }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:wallet_id) }
    it { is_expected.to validate_presence_of(:callback_url) }
    it { is_expected.to validate_uniqueness_of(:incoming_address) }
    it { is_expected.to validate_url_of(:callback_url) }
  end

  describe 'before_create :generate_incoming_address' do
    let(:wallet) { build(:wallet) }

    before { allow(wallet).to receive(:generate_incoming_address).and_return('12345') }

    context 'when an incoming_address was provided' do
      let(:invoice) { build(:invoice, wallet: wallet, incoming_address: '54321') }

      it 'does not overwrite the provided address' do
        expect { invoice.save }.not_to change(invoice, :incoming_address)
      end
    end

    context 'when an incoming_address was not provided' do
      let(:invoice) { build(:invoice, wallet: wallet, incoming_address: nil) }

      it 'generates an incoming address from the wallet' do
        expect { invoice.save }.to change(invoice, :incoming_address).from(nil).to('12345')
      end
    end
  end
end
