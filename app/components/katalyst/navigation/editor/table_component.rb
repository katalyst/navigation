# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class TableComponent < BaseComponent
        renders_many :items, ->(item) do
          row = RowComponent.new(item:, menu:)
          row.with_content(render(ItemComponent.new(item:, menu:)))
          row
        end

        private

        def default_html_attributes
          {
            class: "katalyst--navigation--editor",
            data:  {
              controller:                        "navigation--editor--list",
              action:                            %w[
                dragstart->navigation--editor--list#dragstart
                dragover->navigation--editor--list#dragover
                drop->navigation--editor--list#drop
                dragend->navigation--editor--list#dragend
                keyup.esc@document->navigation--editor--list#dragend
              ],
              "navigation--editor--menu-target": "menu",
            },
            role:  "list",
          }
        end
      end
    end
  end
end
