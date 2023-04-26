# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallet do
  let(:wallet) { build(:wallet) }

  describe 'validations' do
    subject { wallet }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:port) }
    it { is_expected.to validate_uniqueness_of(:port) }
  end

  describe '#running?' do
    subject { wallet.running? }

    context 'when pid is blank' do
      it { is_expected.to be false }
    end

    context 'when pid is present but no proc running' do
      let(:wallet) { build(:wallet, pid: 1) }

      before { allow(File).to receive(:read).with('/proc/1/cmdline').and_raise(Errno::ENOENT) }

      it { is_expected.to be false }
    end

    context 'when pid is present but the proc has the wrong details' do
      let(:wallet) { build(:wallet, pid: 1) }

      before { allow(File).to receive(:read).with('/proc/1/cmdline').and_return('junk') }

      it { is_expected.to be false }
    end

    context 'when pid is present and proc has the correct details' do
      let(:wallet) { build(:wallet, pid: 1) }

      before do
        allow(File).to receive(:read).with('/proc/1/cmdline').and_return("monero-wallet-rpc --stagenet --daemon-host=some.host --wallet-file=wallets/#{wallet.name} --password=password --rpc-bind-port=#{wallet.port} --tx-notify='/junk'")
      end

      it { is_expected.to be true }
    end
  end
end
