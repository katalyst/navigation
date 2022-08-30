# frozen_string_literal: true

module Katalyst
  module Navigation
    module GarbageCollection
      extend ActiveSupport::Concern

      def clean_stale_versions(menu)
        # find all the versions that are not linked to the menu
        orphaned_versions = Menu::Version.active_versions(menu).invert_where
        # create a list of links that are could be orphaned (links of orphaned versions)
        possible_orphaned_links = orphaned_versions.map { |k| k.nodes.map(&:id) }.flatten.uniq

        # remove the links that are mentioned by latest + current from orphaned set
        used_links     = Menu::Version.active_versions(menu).pluck(:nodes).map { |k| k.map(&:id) }.flatten.uniq
        orphaned_links = possible_orphaned_links - used_links

        # delete orphaned links and orphaned versions
        unless orphaned_links.empty?
          Link.where("id in(?) and updated_at <= ?", orphaned_links,
                     Time.zone.today.to_time.beginning_of_day).destroy_all
        end
        orphaned_versions.destroy_all unless orphaned_versions.empty?
      end
    end
  end
end
