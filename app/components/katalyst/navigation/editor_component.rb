# frozen_string_literal: true

module Katalyst
  module Navigation
    class EditorComponent < Editor::BaseComponent
      include ::Turbo::FramesHelper

      def status_bar
        @status_bar ||= Editor::StatusBarComponent.new(menu:)
      end

      def item_editor(item:)
        Editor::ItemEditorComponent.new(menu:, item:)
      end

      def item(item:)
        Editor::ItemComponent.new(menu:, item:)
      end

      def errors
        @errors ||= Katalyst::Navigation.config.errors_component.constantize.new(menu:)
      end

      private

      def default_html_attributes
        {
          id:    menu_form_id,
          class: "navigation--editor",
          data:  {
            controller:                                 "navigation--editor--menu",
            action:                                     %w[
              submit->navigation--editor--menu#reindex
              navigation:drop->navigation--editor--menu#drop
              navigation:reindex->navigation--editor--menu#reindex
              navigation:reset->navigation--editor--menu#reset
              turbo:render@document->navigation--editor--menu#connect
            ],
            "navigation--editor--menu-max-depth-value": menu.depth,
          },
        }
      end
    end
  end
end
