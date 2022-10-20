# frozen_string_literal: true

module Katalyst
  module Navigation
    class Heading < Item
      validates :title, presence: true
    end
  end
end
