# frozen_string_literal: true

module Katalyst
  module Navigation
    # Renders an HTML button using `button_to`.
    class Button < Item
      HTTP_METHODS = %i[get post patch put delete].index_by(&:itself).freeze

      enum method: HTTP_METHODS, _prefix: :http

      validates :title, :url, :http_method, presence: true
      validates :http_method, inclusion: { in: HTTP_METHODS.values.map(&:to_s) }

      def self.permitted_params
        super + %i[http_method]
      end
    end
  end
end
