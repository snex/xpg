# frozen_string_literal: true

class AddPaymentIdToInvoices < ActiveRecord::Migration[7.0]
  def up
    change_table :invoices, bulk: true do
      remove_column         :invoices, :incoming_address
      add_column            :invoices, :incoming_address, :string, null: false, default: ''
      add_column            :invoices, :payment_id,       :string, null: false, default: ''
      change_column_default :invoices, :incoming_address, nil
      change_column_default :invoices, :payment_id,       nil
      add_index             :invoices, %i[incoming_address payment_id], unique: true
    end
  end

  def down
    change_table :invoices, bulk: true do
      remove_column         :invoices, :payment_id
      remove_column         :invoices, :incoming_address
      add_column            :invoices, :incoming_address, :string, null: false, default: ''
      change_column_default :invoices, :incoming_address, nil
      add_index             :invoices, :incoming_address, unique: true
    end
  end
end
