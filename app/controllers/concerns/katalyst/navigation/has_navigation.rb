# frozen_string_literal: true

module Katalyst
  module Navigation
    module HasNavigation
      extend ActiveSupport::Concern

      module NavigationHelper
        def navigation_menu_for(slug)
          @navigation_menus[slug.to_s]
        end
      end

      included do
        helper Katalyst::Navigation::FrontendHelper
        helper NavigationHelper

        before_action :set_navigation_menus
      end

      protected

      def set_navigation_menus
        @navigation_menus = Katalyst::Navigation::Menu.includes(:published_version).index_by(&:slug)
      end
    end
  end
end
