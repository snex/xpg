require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#place_active_tab_class' do
    subject { helper.place_active_tab_class(:test) }

    context 'when the current page is the passed in controller' do
      before { allow(helper).to receive(:current_page?).with(controller: :test).and_return(true) }

      it { is_expected.to eq('link-secondary active') }
    end

    context 'when the current page is not the passed in controller' do
      before { allow(helper).to receive(:current_page?).with(controller: :test).and_return(false) }

      it { is_expected.to eq('link-dark') }
    end
  end
end
