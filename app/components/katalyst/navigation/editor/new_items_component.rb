# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class NewItemsComponent < BaseComponent
        include ::Turbo::FramesHelper

        renders_many :items, Editor::NewItemComponent

        def items
          Katalyst::Navigation.config.items.map do |item_class|
            item_class = item_class.safe_constantize if item_class.is_a?(String)
            item_class.new(menu:)
          end
        end
      end
    end
  end
end
