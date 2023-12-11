# frozen_string_literal: true

module Katalyst
  module Navigation
    module Types
      # Data serialization/deserialization for Katalyst::Navigation::Menu::Version structural data
      class NodesType < ActiveRecord::Type::Json
        def serialize(value)
          super(value.as_json)
        end

        def deserialize(value)
          case value
          when nil
            nil
          when String
            deserialize(super)
          when Hash
            deserialize_params(value)
          when Array
            deserialize_array(value)
          end
        end

        private

        # Deserialize a params-style array, e.g. "0" => { ... }
        def deserialize_params(value)
          value.map do |index, attributes|
            Node.new(index:, **attributes)
          end.select(&:id).sort_by(&:index)
        end

        def deserialize_array(value)
          value.map.with_index do |attributes, index|
            Node.new(index:, **attributes)
          end.select(&:id).sort_by(&:index)
        end
      end
    end
  end
end
