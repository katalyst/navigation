# frozen_string_literal: true

module Katalyst
  module Navigation
    class Card < Item
      has_one_attached :wide_image
      has_one_attached :square_image

      validates :title, :url, :wide_image, :square_image, presence: true
      validates :alt_text, presence: true, if: -> { wide_image.present? || square_image.present? }
    end
  end
end
