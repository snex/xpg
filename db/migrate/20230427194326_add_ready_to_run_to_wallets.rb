# frozen_string_literal: true

class AddReadyToRunToWallets < ActiveRecord::Migration[7.0]
  def change
    change_table :wallets do |t|
      t.boolean :ready_to_run, null: false, default: false
    end
  end
end
