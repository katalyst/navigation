# frozen_string_literal: true

module Katalyst
  module Navigation
    # STI base class for menu items (headings, links and buttons)
    class Item < ApplicationRecord
      TARGETS = %w[self top blank kpop].index_by(&:itself).freeze

      belongs_to :menu, inverse_of: :items, class_name: "Katalyst::Navigation::Menu"

      after_initialize :initialize_tree

      attr_accessor :parent, :children, :index, :depth

      attribute :target, :string, default: "self"

      enum target: TARGETS, _prefix: :target

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
        if target_self?
          {} # default
        elsif browser_target?
          { target: "_#{target}" } # browser will handle this target
        else
          { data: { turbo_frame: target } } # turbo target
        end
      end

      def browser_target?
        target_self? || target_blank? || target_top?
      end

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end
    end
  end
end
