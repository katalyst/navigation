# frozen_string_literal: true

module Katalyst
  module Navigation
    module FrontendHelper
      mattr_accessor :navigation_builder

      # Render a navigation menu. Caches based on the published version's id.
      #
      # @param(menu: Katalyst::Navigation::Menu)
      # @return Structured HTML containing top level + nested navigation links
      def render_navigation_menu(menu, item: {}, list: {}, **options)
        return unless menu&.published_version&.present?

        cache menu.published_version do
          builder = default_navigation_builder_class.new(self, menu: options, item: item, list: list)
          concat builder.render(menu.published_tree)
        end
      end

      # Render items without a wrapper list, useful for inline rendering of items
      #
      # @param(items: [Katalyst::Navigation::Item])
      # @return Structured HTML containing top level + nested navigation links
      def render_navigation_items(items, list: {}, **options)
        builder = default_navigation_builder_class.new(self, item: options, list: list)
        capture do
          items.each do |item|
            concat builder.render_item(item)
          end
        end
      end

      private

      def default_navigation_builder_class
        builder = controller.try(:default_navigation_builder) || Frontend::Builder
        builder.respond_to?(:constantize) ? builder.constantize : builder
      end
    end
  end
end
