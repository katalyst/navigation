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

      config_accessor(:errors_component) { "Katalyst::Navigation::Editor::ErrorsComponent" }

      config_accessor(:base_controller) { "ApplicationController" }
    end
  end
end
