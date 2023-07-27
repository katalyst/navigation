# frozen_string_literal: true

module Katalyst
  module Navigation
    # Renders an HTML button using `button_to`.
    class Button < Item
      HTTP_METHODS = %w[get post patch put delete].index_by(&:itself).freeze

      attribute :http_method, :string, default: "get"

      enum http_method: HTTP_METHODS, _prefix: :http

      validates :title, :url, :http_method, presence: true

      def self.permitted_params
        super + %i[http_method]
      end

      def options_for_target
        options = super

        unless http_get? || target_blank?
          options.deep_merge!({ data: { turbo_method: http_method } })
        end

        options
      end
    end
  end
end
