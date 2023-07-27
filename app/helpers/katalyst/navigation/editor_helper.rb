# frozen_string_literal: true

module Katalyst
  module Navigation
    module EditorHelper
      def navigation_editor_new_items(menu)
        Katalyst::Navigation.config.items.map do |item_class|
          item_class = item_class.safe_constantize if item_class.is_a?(String)
          item_class.new(menu: menu)
        end
      end

      def navigation_editor_menu(menu:, **options, &block)
        Editor::Menu.new(self, menu).build(options, &block)
      end

      def navigation_editor_list(menu:, items: menu.draft_items, **options)
        Editor::List.new(self, menu).build(options) do |list|
          list.items(*items) if items.present?
        end
      end

      # Generate items without their list wrapper, similar to form_with/fields
      def navigation_editor_items(item:, menu: item.menu)
        Editor::List.new(self, menu).items(item)
      end

      # Generate a turbo stream fragment that will show structural errors to the user.
      def navigation_editor_errors(menu:, **options)
        turbo_stream.replace(dom_id(menu, :errors),
                             Editor::Errors.new(self, menu).build(**options))
      end

      # Generate a new item template.
      def navigation_editor_new_item(item:, menu: item.menu, **options, &block)
        Editor::NewItem.new(self, menu).build(item, **options, &block)
      end

      def navigation_editor_item(item:, menu: item.menu, **options, &block)
        Editor::Item.new(self, menu).build(item, **options, &block)
      end

      def navigation_editor_item_fields(item:, menu: item.menu)
        Editor::Item.new(self, menu).fields(item)
      end

      def navigation_editor_status_bar(menu:, **options)
        Editor::StatusBar.new(self, menu).build(**options)
      end
    end
  end
end
