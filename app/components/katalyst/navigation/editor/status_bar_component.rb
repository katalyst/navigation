# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class StatusBarComponent < BaseComponent
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          navigation:change@document->#{STATUS_BAR_CONTROLLER}#change
          turbo:morph-element->#{STATUS_BAR_CONTROLLER}#morph
        ACTIONS

        attr_reader :container

        def call
          tag.div(**html_attributes) do
            concat status(:published, last_update: l(menu.updated_at, format: :short))
            concat status(:draft)
            concat status(:dirty)
            concat actions
          end
        end

        def status(state, **)
          tag.span(t("views.katalyst.navigation.editor.#{state}_html", **),
                   class: "status-text",
                   data:  { state => "" })
        end

        def actions
          tag.menu do
            concat action(:discard, class: "button", data: { text_button: "" })
            concat action(:revert, class: "button", data: { text_button: "" }) if menu.state == :draft
            concat action(:save, class: "button", data: { ghost_button: "" })
            concat action(:publish, class: "button")
          end
        end

        def action(action, **)
          tag.li do
            button_tag(t("views.katalyst.navigation.editor.#{action}"),
                       name:  "commit",
                       value: action,
                       form:  menu_form_id,
                       **)
          end
        end

        private

        def default_html_attributes
          {
            data: {
              controller: STATUS_BAR_CONTROLLER,
              action:     ACTIONS,
              state:      menu.state,
            },
          }
        end
      end
    end
  end
end
