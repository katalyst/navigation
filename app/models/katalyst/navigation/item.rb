# frozen_string_literal: true

module Katalyst
  module Navigation
    # STI base class for menu items (headings, links and buttons)
    class Item < ApplicationRecord
      belongs_to :menu, inverse_of: :items, class_name: "Katalyst::Navigation::Menu"

      after_initialize :initialize_tree

      attr_accessor :parent, :children, :index, :depth

      def layout?
        is_a? Layout
      end

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end
    end
  end
end
