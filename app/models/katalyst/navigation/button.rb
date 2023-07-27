# frozen_string_literal: true

module Katalyst
  module Navigation
    # Renders an HTML button using `button_to`.
    class Button < Item
      include HasLink

      validates :title, presence: true
    end
  end
end
