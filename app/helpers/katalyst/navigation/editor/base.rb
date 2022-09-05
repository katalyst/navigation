# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class Base
        MENU_CONTROLLER       = "navigation--editor--menu"
        LIST_CONTROLLER       = "navigation--editor--list"
        ITEM_CONTROLLER       = "navigation--editor--item"
        STATUS_BAR_CONTROLLER = "navigation--editor--status-bar"
        NEW_ITEM_CONTROLLER   = "navigation--editor--new-item"

        ATTRIBUTES_SCOPE = "menu[items_attributes][]"
        TURBO_FRAME      = "navigation--editor--item-frame"

        attr_accessor :template, :menu

        delegate_missing_to :template

        def initialize(template, menu)
          self.template = template
          self.menu     = menu
        end

        def menu_form_id
          dom_id(menu, :items)
        end

        private

        def add_option(options, key, *path)
          if path.length > 1
            add_option(options[key] ||= {}, *path)
          else
            options[key] = [options[key], *path].compact.join(" ")
          end
        end
      end
    end
  end
end
