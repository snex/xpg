# frozen_string_literal: true

class AddDefaultExpiryFields < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :default_expiry_ttl, :integer
  end
end
