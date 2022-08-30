# frozen_string_literal: true

module Katalyst
  module Navigation
    module GarbageCollection
      extend ActiveSupport::Concern

      included do
        after_update :remove_stale_versions
      end

      def remove_stale_versions
        transaction do
          # find all the versions that are not linked to the menu
          orphaned_versions = versions.inactive

          next unless orphaned_versions.any?

          # find links that are not included in active versions
          orphaned_items = items.pluck(:id) - versions.active.pluck(:nodes).flat_map { |k| k.map(&:id) }.uniq

          # delete orphaned links with a 2 hour grace period to allow for in-progress editing
          items.where(id: orphaned_items, updated_at: ..2.hours.ago).destroy_all

          # delete orphaned versions without a grace period as they can only be created by updates
          orphaned_versions.destroy_all
        end
      end
    end
  end
end
