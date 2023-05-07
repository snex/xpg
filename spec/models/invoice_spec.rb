# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:invoice) { build(:invoice) }

  describe 'associations' do
    it { is_expected.to belong_to(:wallet) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:callback_url) }
  end

  describe 'before_create :generate_incoming_address' do
    let(:wallet) { build(:wallet) }
    let(:invoice) { build(:invoice, wallet: wallet, incoming_address: nil) }

    before { allow(wallet).to receive(:generate_incoming_address).and_return('12345') }

    it 'generates an incoming address from the wallet' do
      expect { invoice.save }.to change(invoice, :incoming_address).from(nil).to('12345')
    end
  end
end
