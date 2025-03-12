# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class NewItemComponent < BaseComponent
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          #{NEW_ITEMS_CONTROLLER}#add
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
            role: "listitem",
            data: {
              item_type:,
              action:    ACTIONS,
            },
          }
        end
      end
    end
  end
end
