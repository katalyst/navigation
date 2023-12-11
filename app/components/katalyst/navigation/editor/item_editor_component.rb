# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class ItemEditorComponent < BaseComponent
        include ::Turbo::FramesHelper

        module Helpers
          def prefix_partial_path_with_controller_namespace
            false
          end
        end

        def call
          tag.div(**html_attributes) do
            helpers.extend(Helpers)
            helpers.render(item.model_name.param_key, item:, path:)
          end
        end

        def id
          "item-editor-#{item.id}"
        end

        def title
          if item.persisted?
            "Edit #{item.model_name.human.downcase}"
          else
            "New #{item.model_name.human.downcase}"
          end
        end

        def path
          if item.persisted?
            view_context.katalyst_navigation.menu_item_path(menu, item)
          else
            view_context.katalyst_navigation.menu_items_path(menu)
          end
        end

        def default_html_attributes
          {
            id:,
            class: "navigation--item-editor",
          }
        end
      end
    end
  end
end
