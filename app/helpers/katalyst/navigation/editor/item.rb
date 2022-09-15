# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class Item < Base
        attr_accessor :item

        def build(item, **options, &block)
          self.item = item
          tag.div **default_options(id: dom_id(item), **options) do
            concat(capture { yield self }) if block
            concat fields(item)
          end
        end

        def accordion_actions
          tag.div role: "toolbar", data: { tree_accordion_controls: "" } do
            concat tag.span(role: "button", value: "collapse",
                            data: { action: "click->#{MENU_CONTROLLER}#collapse", title: "Collapse tree" })
            concat tag.span(role: "button", value: "expand",
                            data: { action: "click->#{MENU_CONTROLLER}#expand", title: "Expand tree" })
          end
        end

        def item_actions
          tag.div role: "toolbar", data: { tree_controls: "" } do
            concat tag.span(role: "button", value: "de-nest",
                            data: { action: "click->#{MENU_CONTROLLER}#deNest", title: "Outdent" })
            concat tag.span(role: "button", value: "nest",
                            data: { action: "click->#{MENU_CONTROLLER}#nest", title: "Indent" })
            concat link_to("", edit_item_link,
                           role: "button", title: "Edit", value: "edit",
                           data: { turbo_frame: TURBO_FRAME })
            concat tag.span(role: "button", value: "remove",
                            data: { action: "click->#{MENU_CONTROLLER}#remove", title: "Remove" })
          end
        end

        def edit_item_link
          item.persisted? ? edit_menu_item_path(item.menu, item) : new_menu_item_path(item.menu, type: item.type)
        end

        def fields(item)
          template.fields(ATTRIBUTES_SCOPE, model: item, index: nil, skip_default_ids: true) do |f|
            concat f.hidden_field(:id)
            concat f.hidden_field(:depth)
            concat f.hidden_field(:index)
          end
        end

        private

        def default_options(options)
          add_option(options, :data, :controller, ITEM_CONTROLLER)

          options
        end
      end
    end
  end
end
