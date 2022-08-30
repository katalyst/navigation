# frozen_string_literal: true

module Katalyst
  module Navigation
    module HasTree
      # Constructs a tree from an ordered list of items with depth.
      #  * items that have higher depth than their predecessor are nested as `children`.
      #  * items with the same depth become siblings.
      def tree
        items.reduce(Builder.new, &:add).tree
      end

      class Builder
        attr_reader :current, :depth, :children, :tree

        def initialize
          @depth    = 0
          @children = @tree = []
        end

        def add(node)
          if node.depth == depth
            node.parent = current
            children << node
            self
          elsif node.depth > depth
            push(children.last)
            add(node)
          else
            pop
            add(node)
          end
        end

        private

        attr_writer :current, :depth, :children

        # Add node to the top of builder stacks
        def push(node)
          self.depth += 1
          self.current  = node
          self.children = node.children = []
          node
        end

        # Remove current from builder stack
        def pop
          previous = current
          self.depth -= 1
          if depth.zero?
            self.current  = nil
            self.children = tree
          else
            self.current  = previous.parent
            self.children = current.children
          end
          previous
        end
      end
    end
  end
end
