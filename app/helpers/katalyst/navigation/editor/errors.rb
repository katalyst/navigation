# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class Errors < Base
        def build(**options)
          turbo_frame_tag dom_id(menu, :errors) do
            next unless menu.errors.any?

            tag.div(class: "navigation-errors", **options) do
              tag.h2("Errors in navigation") +
                tag.ul(class: "errors") do
                  menu.errors.each do |error|
                    concat(tag.li(error.message))
                  end
                end
            end
          end
        end
      end
    end
  end
end
