# frozen_string_literal: true

module ApplicationHelper
  def place_active_tab_class(controller)
    return 'link-secondary active' if current_page?(controller: controller)
    'link-dark'
  end
end
