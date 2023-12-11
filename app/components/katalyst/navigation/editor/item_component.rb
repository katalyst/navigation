# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class ItemComponent < BaseComponent
        include KpopHelper

        def edit_item_link
          if item.persisted?
            helpers.katalyst_navigation.edit_menu_item_path(menu, item)
          else
            helpers.katalyst_navigation.new_menu_item_path(item.menu, type: item.type)
          end
        end

        private

        def default_html_attributes
          {
            id:   dom_id(item),
            data: {
              controller: ITEM_CONTROLLER,
            },
          }
        end
      end
    end
  end
end
