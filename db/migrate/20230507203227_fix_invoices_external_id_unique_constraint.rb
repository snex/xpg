# frozen_string_literal: true

class FixInvoicesExternalIdUniqueConstraint < ActiveRecord::Migration[7.0]
  def up
    change_table :invoices, bulk: true do
      remove_column :invoices, :external_id
      add_column :invoices, :external_id, :string, null: false, default: ''
      add_index :invoices, %i[wallet_id external_id], unique: true
    end
  end

  def down
    change_table :invoices do |t|
      t.string :external_id, null: false, default: '', index: { unique: true }
    end
  end
end
