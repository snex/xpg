# frozen_string_literal: true

module WalletFileService
  def initialize(wallet)
    @wallet = wallet
  end

  def write_config_file!
    File.open("wallets/#{@wallet.name}.config", 'w') do |f|
      config.split('&').each do |arg|
        f.puts arg.gsub(/%\w+%/, config_hash)
      end
    end

    FileUtils.chmod('u=rw,go=-rwx', "wallets/#{@wallet.name}.config")
  end

  private

  def config_hash
    {
      '%daemon%'    => Rails.application.config.monero_daemon,
      '%rpc_creds%' => @wallet.rpc_creds,
      '%port%'      => @wallet.port.to_s,
      '%name%'      => @wallet.name,
      '%password%'  => @wallet.password,
      '%id%'        => @wallet.id.to_s,
      '%tx_notify%' => Rails.root.join('lib/process_tx.sh')
    }
  end
end
