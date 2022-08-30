# frozen_string_literal: true

module Katalyst
  module Navigation
    # A menu is a list of items (links, buttons, etc) with order and depth creating a tree structure.
    # Items should be copy-on-write, as menus store their structure as copy-on-write versions using item ids.
    class Menu < ApplicationRecord
      include GarbageCollection

      before_destroy :unset_versions

      belongs_to :draft_version,
                 autosave:   true,
                 class_name: "Katalyst::Navigation::Menu::Version",
                 inverse_of: :parent,
                 optional:   true
      belongs_to :published_version,
                 class_name: "Katalyst::Navigation::Menu::Version",
                 inverse_of: :parent,
                 optional:   true

      has_many :versions,
               class_name:  "Katalyst::Navigation::Menu::Version",
               dependent:   :delete_all,
               foreign_key: :parent_id,
               inverse_of:  :parent,
               validate:    true do
        def active
          menu = proxy_association.owner
          where(id: [menu.published_version_id, menu.draft_version_id].uniq.compact)
        end
      end

      has_many :items,
               autosave:   true,
               class_name: "Katalyst::Navigation::Item",
               dependent:  :delete_all,
               inverse_of: :menu,
               validate:   true

      validates :title, :slug, presence: true
      validates :slug, uniqueness: true

      # A menu is in draft mode if it has an unpublished draft or it has no published version.
      # @return the current state of the menu, either `published` or `draft`
      def state
        if published_version_id && published_version_id == draft_version_id
          :published
        else
          :draft
        end
      end

      # Promotes the draft version to become the published version
      def publish!
        update!(published_version: draft_version)
        self
      end

      # Reverts the draft version to the current published version
      def revert!
        update!(draft_version: published_version)
        self
      end

      # Updates the current draft version with new structure. Attributes should be structural information about the
      # items, e.g. `{index => {id:, depth:}` or `[{id:, depth:}]`.
      #
      # This method conforms to the behaviour of `accepts_nested_attributes_for` so that it can be used with rails form
      # helpers.
      def items_attributes=(attributes)
        next_version.nodes = attributes
      end

      delegate :nodes, :items, :tree, to: :published_version, prefix: :published, allow_nil: true
      delegate :nodes, :items, :tree, to: :draft_version, prefix: :draft, allow_nil: true

      private

      def unset_versions
        update(draft_version: nil, published_version: nil)
      end

      # Returns an unsaved copy of draft version for accumulating changes.
      def next_version
        if draft_version.nil?
          build_draft_version
        elsif draft_version.persisted?
          self.draft_version = draft_version.dup
        else
          draft_version
        end
      end

      class Version < ApplicationRecord
        include HasTree

        belongs_to :parent, class_name: "Katalyst::Navigation::Menu", inverse_of: :versions

        attribute :nodes, Types::NodesType.new, default: -> { [] }

        def items
          items = parent.items.where(id: nodes.map(&:id)).index_by(&:id)

          nodes.map do |node|
            item       = items[node.id]
            item.index = node.index
            item.depth = node.depth
            item
          end
        end
      end
    end
  end
end
