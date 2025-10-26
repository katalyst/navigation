# frozen_string_literal: true

module Katalyst
  module Navigation
    class Config
      attr_accessor :base_controller,
                    :errors_component,
                    :items

      def initialize
        self.base_controller = "ApplicationController"
        self.errors_component = "Katalyst::Navigation::Editor::ErrorsComponent"
        self.items = %w[
          Katalyst::Navigation::Heading
          Katalyst::Navigation::Link
          Katalyst::Navigation::Button
        ]
      end
    end
  end
end
