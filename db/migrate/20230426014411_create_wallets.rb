# frozen_string_literal: true

class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.string  :name,      null: false, index: { unique: true }
      t.string  :password,  null: false
      t.string  :rpc_creds, null: false
      t.integer :port,      null: false, index: { unique: true }
      t.integer :pid

      t.timestamps
    end
  end
end
