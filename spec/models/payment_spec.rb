# frozen_string_literal: true

RSpec.describe Payment do
  let(:payment) { build(:payment) }

  describe 'associations' do
    it { is_expected.to belong_to(:invoice) }
  end

  describe 'validations' do
    subject { payment }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:monero_tx_id) }
    it { is_expected.to validate_uniqueness_of(:monero_tx_id) }
  end
end
