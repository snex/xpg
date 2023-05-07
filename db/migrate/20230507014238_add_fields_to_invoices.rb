# frozen_string_literal: true

class AddFieldsToInvoices < ActiveRecord::Migration[7.0]
  def change
    change_table :invoices, bulk: true do |t|
      t.string :incoming_address, null: false, index: { unique: true }
      t.string :callback_url,     null: false
    end
  end
end
