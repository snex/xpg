# frozen_string_literal: true

RSpec.describe WalletsHelper do
  describe '#display_default_expiry_ttl' do
    subject { helper.display_default_expiry_ttl(wallet) }

    context 'when wallet.default_expiry_ttl is blank' do
      let(:wallet) { build(:wallet, default_expiry_ttl: nil) }

      it { is_expected.to eq(t('misc.n_a')) }
    end

    context 'when wallet.default_expiry_ttl is present' do
      let(:wallet) { build(:wallet, default_expiry_ttl: 45) }

      it { is_expected.to eq("45 #{t('misc.minutes')}") }
    end
  end
end
