# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  let(:invoice) { build(:invoice) }

  describe 'associations' do
    it { is_expected.to belong_to(:wallet) }
  end
end
