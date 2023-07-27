# frozen_string_literal: true

module Katalyst
  module Navigation
    # Renders an HTML link using `link_to`.
    class Link < Item
      include HasLink

      validates :title, presence: true
    end
  end
end
