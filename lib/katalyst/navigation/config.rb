# frozen_string_literal: true

require "active_support/configurable"

module Katalyst
  module Navigation
    class Config
      include ActiveSupport::Configurable

      config_accessor(:items) do
        %w[
          Katalyst::Navigation::Heading
          Katalyst::Navigation::Link
          Katalyst::Navigation::Button
        ]
      end
    end
  end
end
