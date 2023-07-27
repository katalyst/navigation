# frozen_string_literal: true

module Katalyst
  module Navigation
    module HasLink
      extend ActiveSupport::Concern

      HTTP_METHODS = %w[get post patch put delete].index_by(&:itself).freeze
      TARGETS      = %w[self top blank kpop].index_by(&:itself).freeze

      class_methods do
        def permitted_params
          super + %i[url http_method target]
        end
      end

      included do
        validates :url, :http_method, :target, presence: true

        attribute :http_method, :string, default: "get"

        enum http_method: HTTP_METHODS, _prefix: :http

        attribute :target, :string, default: "self"

        enum target: TARGETS, _prefix: :target
      end

      def link_attributes
        options = if target_self?
                    {} # default
                  elsif target_blank? || target_top?
                    { target: "_#{target}" } # browser will handle this target
                  else
                    { data: { turbo_frame: target } } # turbo target
                  end

        options.deep_merge!({ data: { turbo_method: http_method } }) unless http_get? || target_blank?

        options
      end
    end
  end
end
