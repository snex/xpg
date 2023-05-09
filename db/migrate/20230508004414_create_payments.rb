# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :invoice,  null: false, type: :uuid, foreign_key: true
      t.string :amount,       null: false
      t.string :monero_tx_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
