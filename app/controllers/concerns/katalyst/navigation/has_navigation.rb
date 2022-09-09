# frozen_string_literal: true

module Katalyst
  module Navigation
    # Preloads navigation menus before content is rendered.
    module HasNavigation
      extend ActiveSupport::Concern

      # Override the default navigation builder for all views rendered by this
      # controller and any of its descendants. Accepts a subclass of
      # Katalyst::Navigation::Frontend::Builder.
      #
      # For example, given a form builder:
      #
      #   class AdminNavBuilder < Katalyst::Navigation::Frontend::Builder
      #     def render_item(item)
      #     end
      #   end
      #
      # The controller specifies a form builder as its default:
      #
      #   class AdminAreaController < ApplicationController
      #     default_navigation_builder AdminNavBuilder
      #   end
      #
      # Then in the view any form using +navigation_menu_with+ will be an instance of the
      # specified navigation builder:
      #
      #   <%= navigation_menu_with(menu: @menu) %>
      module NavigationBuilder
        extend ActiveSupport::Concern

        included do
          class_attribute :_default_navigation_builder, instance_accessor: false
        end

        class_methods do
          # Set the navigation builder to be used as the default for all navs
          # in the views rendered by this controller and its subclasses.
          #
          # @param builder {Katalyst::Navigation::Frontend::Builder}
          def default_navigation_builder(builder)
            self._default_navigation_builder = builder
          end
        end

        # Default navigation builder for the controller
        #
        # @return {Katalyst::Navigation::Frontend::Builder}
        def default_navigation_builder
          self.class._default_navigation_builder
        end
      end

      # Provide an accessor for navigation menus
      module NavigationHelper
        # Retrieves the preloaded menu that matches the given slug.
        #
        # @return {Katalyst::Navigation::Menu} menu with the given slug
        def navigation_menu_for(slug)
          @navigation_menus[slug.to_s]
        end

        # @see ActionView::Helpers::ControllerHelper#assign_controller
        def assign_controller(controller)
          super

          if controller.respond_to?(:default_navigation_builder)
            @_default_navigation_builder = controller.default_navigation_builder
          end
        end
      end

      included do
        include NavigationBuilder

        helper Katalyst::Navigation::FrontendHelper
        helper NavigationHelper

        # @see ActionController::Rendering#render
        def render(*args)
          set_navigation_menus

          super
        end
      end

      protected

      def set_navigation_menus
        @navigation_menus = Katalyst::Navigation::Menu.includes(:published_version).index_by(&:slug)
      end
    end
  end
end
