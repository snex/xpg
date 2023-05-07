# frozen_string_literal: true

class ConvertInvoiceAmountToText < ActiveRecord::Migration[7.0]
  # since we are encrypting the amount column, it needs to be a text
  def up
    change_column :invoices, :amount, :string, null: false
  end

  def down
    change_column :invoices, :amount, :bigint, null: false
  end
end
