# frozen_string_literal: true

module Katalyst
  module Navigation
    # Renders an HTML link using `link_to`.
    class Link < Item
      validates :title, :url, presence: true
    end
  end
end
