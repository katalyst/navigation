# frozen_string_literal: true

module Katalyst
  module Navigation
    module FrontendHelper
      mattr_accessor :navigation_builder

      attr_internal :default_navigation_builder

      # Render a navigation menu. Caches based on the published version's id.
      #
      # @param(menu: Katalyst::Navigation::Menu)
      # @return Structured HTML containing top level + nested navigation links
      def navigation_menu_with(menu:, **options)
        builder = navigation_builder(**options)
        menu    = menu.is_a?(Symbol) ? navigation_menu_for(menu) : menu

        return unless menu&.published_version&.present?

        cache menu.published_version do
          concat builder.render(menu.published_tree)
        end
      end

      # Render items without a wrapper list, useful for inline rendering of items
      #
      # @param(items: [Katalyst::Navigation::Item])
      # @return Structured HTML containing top level + nested navigation links
      def navigation_items_with(items:, **options)
        builder = navigation_builder(**options)

        capture do
          items.each do |item|
            concat builder.render_item(item)
          end
        end
      end

      private

      def navigation_builder(**options)
        builder = options.delete(:builder) || default_navigation_builder_class
        builder.new(self, **options)
      end

      def default_navigation_builder_class
        builder = default_navigation_builder || Frontend::Builder
        builder.respond_to?(:constantize) ? builder.constantize : builder
      end
    end
  end
end
