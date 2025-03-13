# frozen_string_literal: true

module Katalyst
  module Navigation
    class EditorComponent < Editor::BaseComponent
      include ::Turbo::FramesHelper

      ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
        submit->#{MENU_CONTROLLER}#reindex
        navigation:drop->#{MENU_CONTROLLER}#drop
        navigation:reindex->#{MENU_CONTROLLER}#reindex
        navigation:reset->#{MENU_CONTROLLER}#reset
        turbo:render@document->#{MENU_CONTROLLER}#connect
      ACTIONS

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
          id:   menu_form_id,
          data: {
            controller:                           MENU_CONTROLLER,
            action:                               ACTIONS,
            "#{MENU_CONTROLLER}-max-depth-value": menu.depth,
          },
        }
      end
    end
  end
end
