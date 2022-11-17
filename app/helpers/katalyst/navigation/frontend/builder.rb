# frozen_string_literal: true

# rubocop:disable Rails/HelperInstanceVariable
module Katalyst
  module Navigation
    module Frontend
      class Builder
        attr_accessor :template

        delegate_missing_to :@template

        def initialize(template, list: {}, item: {}, **menu_options)
          self.template = template
          @menu_options = menu_options.freeze
          @list_options = list.freeze
          @item_options = item.freeze
        end

        def render(tree)
          tag.ul(**menu_options(tree)) do
            tree.each do |item|
              concat render_item(item)
            end
          end
        end

        def render_item(item)
          return unless item.visible?

          tag.li(**item_options(item)) do
            concat public_send("render_#{item.model_name.param_key}", item)
            concat render_children(item) if item.children.any?
          end
        end

        def render_children(item)
          tag.ul(**list_options(item)) do
            item.children.each do |child|
              concat render_item(child)
            end
          end
        end

        def render_heading(heading)
          tag.span(heading.title)
        end

        def render_link(link)
          link_to(link.title, link.url, link.item_options)
        end

        def render_button(link)
          link_to(link.title, link.url, link.item_options)
        end

        private

        def menu_options(_tree)
          @menu_options
        end

        def list_options(_item)
          @list_options
        end

        def item_options(_item)
          @item_options
        end
      end
    end
  end
end
# rubocop:enable Rails/HelperInstanceVariable
