# frozen_string_literal: true

class DropDefaultOnExternalId < ActiveRecord::Migration[7.0]
  def change
    change_column_default :invoices, :external_id, from: '', to: nil
  end
end
