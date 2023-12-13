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
      def navigation_menu_with(menu:, **)
        builder = navigation_builder(**)
        menu    = navigation_menu_for(menu) if menu.is_a?(Symbol)

        return if menu.blank?

        cache menu do
          concat builder.render(menu.published_tree) if menu.published_version.present?
        end
      end

      # Render items without a wrapper list, useful for inline rendering of items
      #
      # @param(items: [Katalyst::Navigation::Item])
      # @return Structured HTML containing top level + nested navigation links
      def navigation_items_with(items:, **)
        builder = navigation_builder(**)

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
