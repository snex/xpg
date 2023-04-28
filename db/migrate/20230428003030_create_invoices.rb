# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices, id: :uuid do |t|
      t.references :wallet,      null: false, foreign_key: true
      t.bigint     :amount,      null: false
      t.datetime   :expires_at,  null: false
      t.string     :external_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
