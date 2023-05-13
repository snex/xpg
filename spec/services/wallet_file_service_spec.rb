# frozen_string_literal: true

RSpec.describe WalletFileService do
  let(:wallet) { create(:wallet) }
  let(:dummy) do
    Class.new do
      include WalletFileService

      def config
        'rpc-creds=%rpc_creds%&port=%port%&name=%name%&password=%password%&id=%id%&tx-notify=%tx_notify%'
      end
    end
  end
  let(:wfs) { dummy.new(wallet) }

  describe '#write_config_file!' do
    subject(:write_config_file!) { wfs.write_config_file! }

    let(:io) { StringIO.new }
    let(:expected) do
      [
        "rpc-creds=#{wallet.rpc_creds}\n",
        "port=#{wallet.port}\n",
        "name=#{wallet.name}\n",
        "password=#{wallet.password}\n",
        "id=#{wallet.id}\n",
        "tx-notify=#{Rails.root.join('lib/process_tx.sh')}\n"
      ]
    end

    before do
      allow(File).to receive(:open).with("wallets/#{wallet.name}.config", 'w').and_yield(io)
      allow(FileUtils).to receive(:chmod)
    end

    it 'opens the wallet config file for writing' do
      write_config_file!

      expect(File).to have_received(:open).with("wallets/#{wallet.name}.config", 'w').once
    end

    it 'writes config to the wallet config file' do
      write_config_file!
      io.rewind

      expect(io.readlines).to match_array(expected)
    end

    it 'changes the file permissions to rw for user only' do
      write_config_file!

      expect(FileUtils).to have_received(:chmod).with('u=rw,go=-rwx', "wallets/#{wallet.name}.config").once
    end
  end
end
