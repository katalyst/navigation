# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class ItemEditorComponent < ViewComponent::Base
        attr_reader :menu, :item

        alias_method :model, :item

        def initialize(menu:, item:)
          super()

          @menu = menu
          @item = item
        end

        def call
          render("form", model:, scope:, url:, id:)
        end

        def id
          dom_id(item, :form)
        end

        def scope
          :item
        end

        def title
          if item.persisted?
            "Edit #{item.model_name.human.downcase}"
          else
            "New #{item.model_name.human.downcase}"
          end
        end

        def url
          if item.persisted?
            view_context.katalyst_navigation.menu_item_path(menu, item)
          else
            view_context.katalyst_navigation.menu_items_path(menu)
          end
        end
      end
    end
  end
end
