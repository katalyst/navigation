# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class StatusBar < Base
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          navigation:change@document->#{STATUS_BAR_CONTROLLER}#change
        ACTIONS

        def build(**options)
          content_tag(:div, default_options(**options)) do
            concat status(:published, last_update: l(menu.updated_at, format: :short))
            concat status(:draft)
            concat status(:dirty)
            concat actions
          end
        end

        def status(state, **options)
          tag.span(t("views.katalyst.navigation.editor.#{state}_html", **options),
                   class: "status-text",
                   data:  { state => "" })
        end

        def actions
          content_tag(:menu) do
            concat action(:discard, class: "button button--text")
            concat action(:revert, class: "button button--text") if menu.state == :draft
            concat action(:save, class: "button button--secondary")
            concat action(:publish, class: "button button--primary")
          end
        end

        def action(action, **options)
          tag.li do
            button_tag(t("views.katalyst.navigation.editor.#{action}"),
                       name:  "commit",
                       value: action,
                       form:  menu_form_id,
                       **options)
          end
        end

        private

        def default_options(**options)
          add_option(options, :data, :controller, STATUS_BAR_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)
          add_option(options, :data, :state, menu.state)

          options
        end
      end
    end
  end
end
