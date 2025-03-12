# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class BaseComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        MENU_CONTROLLER       = "navigation--editor--menu"
        LIST_CONTROLLER       = "navigation--editor--list"
        ITEM_CONTROLLER       = "navigation--editor--item"
        STATUS_BAR_CONTROLLER = "navigation--editor--status-bar"
        NEW_ITEMS_CONTROLLER = "navigation--editor--new-items"

        attr_accessor :menu, :item

        delegate :config, to: ::Katalyst::Navigation

        def initialize(menu:, item: nil, **)
          super(**)

          @menu = menu
          @item = item
        end

        def call; end

        def menu_form_id
          dom_id(menu, :items)
        end

        private

        def attributes_scope
          "menu[items_attributes][]"
        end

        def inspect
          if item.present?
            "<#{self.class.name} menu: #{menu.inspect}, item: #{item.inspect}>"
          else
            "<#{self.class.name} menu: #{menu.inspect}>"
          end
        end
      end
    end
  end
end
