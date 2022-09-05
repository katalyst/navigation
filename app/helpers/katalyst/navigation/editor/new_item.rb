# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class NewItem < Base
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragstart->#{NEW_ITEM_CONTROLLER}#dragstart
        ACTIONS

        def build(item, **options, &block)
          capture do
            concat(content_tag(:div, **default_options(options)) do
              concat capture(&block)
              concat item_template(item)
            end)
            concat turbo_replace_placeholder(item)
          end
        end

        # Remove items that are incomplete when rendering new items, this
        # causes incomplete items to be removed from the list when the user
        # cancels adding a new item by pressing 'discard' in the new item form.
        def turbo_replace_placeholder(item)
          turbo_stream.replace dom_id(item) do
            navigation_editor_item(item: item, data: { delete: "" })
          end
        end

        # Template is stored inside the new item dom, and copied into drag
        # events when the user initiates drag so that it can be copied into the
        # editor list on drop.
        def item_template(item)
          content_tag(:template, data: { "#{NEW_ITEM_CONTROLLER}-target" => "template" }) do
            navigation_editor_items(item: item)
          end
        end

        private

        def default_options(options)
          add_option(options, :draggable, true)
          add_option(options, :role, "listitem")
          add_option(options, :data, :turbo_frame, TURBO_FRAME)
          add_option(options, :data, :controller, NEW_ITEM_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)

          options
        end
      end
    end
  end
end
