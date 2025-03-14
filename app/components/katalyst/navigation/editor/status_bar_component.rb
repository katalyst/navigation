# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class StatusBarComponent < BaseComponent
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
              controller: "navigation--editor--status-bar",
              action:     %w[
                navigation:change@document->navigation--editor--status-bar#change
                turbo:morph-element->navigation--editor--status-bar#morph
              ],
              state:      menu.state,
            },
          }
        end
      end
    end
  end
end
