# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class NewItemComponent < BaseComponent
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragstart->#{NEW_ITEM_CONTROLLER}#dragstart
        ACTIONS

        with_collection_parameter :item

        def initialize(item:, menu: item.menu)
          super
        end

        def item_component(**)
          ItemComponent.new(item:, menu:, **)
        end

        def row_component(**)
          RowComponent.new(item:, menu:, **)
        end

        def label
          t("katalyst.navigation.editor.new_item.#{item_type}", default: item.model_name.human)
        end

        def item_type
          item.model_name.param_key
        end

        private

        def default_html_attributes
          {
            draggable: "true",
            role:      "listitem",
            data:      {
              item_type:,
              controller: NEW_ITEM_CONTROLLER,
              action:     ACTIONS,
            },
          }
        end
      end
    end
  end
end
