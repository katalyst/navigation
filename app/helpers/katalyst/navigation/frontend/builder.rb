# frozen_string_literal: true

# rubocop:disable Rails/HelperInstanceVariable
module Katalyst
  module Navigation
    module Frontend
      class Builder
        attr_accessor :template

        delegate_missing_to :@template

        def initialize(template, list: {}, item: {}, **menu_attributes)
          self.template    = template
          @menu_attributes = menu_attributes.freeze
          @list_attributes = list.freeze
          @item_attributes = item.freeze
        end

        def render(tree)
          tag.ul(**menu_attributes(tree)) do
            tree.each do |item|
              concat render_item(item)
            end
          end
        end

        def render_item(item)
          return unless item.visible?

          tag.li(**item_attributes(item)) do
            concat public_send(:"render_#{item.model_name.param_key}", item)
            concat render_children(item) if item.children.any?
          end
        end

        def render_children(item)
          tag.ul(**list_attributes(item)) do
            item.children.each do |child|
              concat render_item(child)
            end
          end
        end

        def render_heading(heading)
          tag.span(heading.title)
        end

        def render_link(link)
          link_to(link.title, link.url, **link.link_attributes)
        end

        def render_button(link)
          link_to(link.title, link.url, **link.link_attributes)
        end

        private

        def menu_attributes(_tree)
          @menu_attributes
        end

        def list_attributes(_item)
          @list_attributes
        end

        def item_attributes(_item)
          @item_attributes
        end
      end
    end
  end
end
# rubocop:enable Rails/HelperInstanceVariable
