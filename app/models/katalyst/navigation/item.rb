# frozen_string_literal: true

module Katalyst
  module Navigation
    # STI base class for menu items (headings, links and buttons)
    class Item < ApplicationRecord
      belongs_to :menu, inverse_of: :items, class_name: "Katalyst::Navigation::Menu"

      after_initialize :initialize_tree

      attr_accessor :parent, :children, :index, :depth

      TARGETS = %i[self _top _blank kpop].index_by(&:itself).freeze

      enum method: TARGETS, _prefix: :target

      def self.permitted_params
        %i[
          title
          url
          visible
          target
          type
        ]
      end

      def layout?
        is_a? Layout
      end

      # Entrypoint for combining additional options based on attribute rules
      def item_options
        options_for_target
      end

      def options_for_target
        return {} if target_self?

        if target_self?
          {} # default
        elsif browser_target?
          { target: target } # browser will handle this target
        else
          { data: { turbo_frame: target } } # turbo target
        end
      end

      def browser_target?
        target_self? || target__blank? || target__top?
      end

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end
    end
  end
end
