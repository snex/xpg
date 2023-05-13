# frozen_string_literal: true

module WalletsHelper
  def display_default_expiry_ttl(wallet)
    return t('misc.n_a') unless wallet.default_expiry_ttl?

    "#{wallet.default_expiry_ttl} #{t('misc.minutes')}"
  end
end
