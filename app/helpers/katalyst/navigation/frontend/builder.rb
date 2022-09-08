# frozen_string_literal: true

module Katalyst
  module Navigation
    module Frontend
      class Builder
        attr_accessor :template, :menu_options, :list_options, :item_options

        delegate_missing_to :@template

        def initialize(template, menu: {}, list: {}, item: {})
          self.template     = template
          self.menu_options = menu
          self.list_options = list
          self.item_options = item
        end

        def render(tree)
          tag.ul **menu_options do
            tree.each do |item|
              concat render_item(item)
            end
          end
        end

        def render_item(item)
          return unless item.visible?

          tag.li **item_options do
            concat public_send("render_#{item.model_name.param_key}", item)
            concat render_list(item.children) if item.children.any?
          end
        end

        def render_list(items)
          tag.ul **list_options do
            items.each do |child|
              concat render_item(child)
            end
          end
        end

        def render_link(link)
          link_to(link.title, link.url, item_options)
        end

        def render_button(link)
          link_to(link.title, link.url, **item_options, method: link.http_method)
        end
      end
    end
  end
end
